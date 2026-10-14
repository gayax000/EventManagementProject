using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class NotificationsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ILogger<NotificationsController> _logger;

    public NotificationsController(AppDbContext context, ILogger<NotificationsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    private static readonly Guid FallbackManagerId = Guid.Parse("11111111-1111-1111-1111-111111111111");

    private async Task<Guid> GetManagerUserIdAsync()
    {
        var manager = await _context.Users.FirstOrDefaultAsync(u => u.Email == "manager@eventcraft.lk" || u.RoleId == 2);
        return manager?.UserId ?? FallbackManagerId;
    }

    private async Task SyncExistingEventNotificationsAsync(Guid managerId)
    {
        try
        {
            // Fetch only EventId + minimal fields needed — avoids full-row transfer
            var existingEventIds = await _context.Notifications
                .Where(n => n.EventId != null)
                .Select(n => n.EventId!.Value)
                .Distinct()
                .ToListAsync();

            var existingEventIdSet = new HashSet<Guid>(existingEventIds);

            // Only pull events that have no notification yet — projected, not full entity
            var eventsNeedingNotif = await _context.Events
                .Where(e => !existingEventIdSet.Contains(e.EventId))
                .Select(e => new { e.EventId, e.EventType, e.Title, e.BudgetLimit, e.Status, e.RevisionNotes, e.CreatedAt })
                .ToListAsync();

            var newNotifications = new List<Notification>();

            foreach (var ev in eventsNeedingNotif)
            {
                newNotifications.Add(new Notification
                {
                    UserId = managerId,
                    EventId = ev.EventId,
                    Title = "🆕 New Event Created",
                    Message = $"New {ev.EventType} event \"{ev.Title}\" created by client. Budget: LKR {ev.BudgetLimit:N0}",
                    Type = "NewEvent",
                    IsRead = false,
                    CreatedAt = ev.CreatedAt
                });

                if (ev.Status == "RevisionRequested" && !string.IsNullOrWhiteSpace(ev.RevisionNotes))
                {
                    newNotifications.Add(new Notification
                    {
                        UserId = managerId,
                        EventId = ev.EventId,
                        Title = "📝 Revision Requested",
                        Message = $"Client requested revision for \"{ev.Title}\": \"{ev.RevisionNotes}\"",
                        Type = "RevisionRequest",
                        IsRead = false,
                        CreatedAt = DateTime.UtcNow
                    });
                }

                if (ev.Status == "ClientChoiceSubmitted")
                {
                    newNotifications.Add(new Notification
                    {
                        UserId = managerId,
                        EventId = ev.EventId,
                        Title = "✅ Proposal Option Accepted",
                        Message = $"Client submitted proposal choice for \"{ev.Title}\".",
                        Type = "ProposalAccepted",
                        IsRead = false,
                        CreatedAt = DateTime.UtcNow
                    });
                }
            }

            // Pending payment slips: use projected join to avoid loading full Payment + Booking entities
            var notifEventIds = await _context.Notifications
                .Where(n => n.Type == "PaymentSlipUploaded" && n.EventId != null)
                .Select(n => n.EventId!.Value)
                .ToListAsync();

            var pendingPayments = await _context.Payments
                .Where(p => p.Status == "PendingVerification")
                .Select(p => new { p.AmountPaid, p.PaidAt, EventId = (Guid?)p.Booking!.EventId })
                .Where(p => p.EventId != null && !notifEventIds.Contains(p.EventId!.Value))
                .ToListAsync();

            foreach (var p in pendingPayments)
            {
                newNotifications.Add(new Notification
                {
                    UserId = managerId,
                    EventId = p.EventId,
                    Title = "💳 Payment Slip Uploaded",
                    Message = $"Payment slip of LKR {p.AmountPaid:N0} uploaded. Pending Manager Verification.",
                    Type = "PaymentSlipUploaded",
                    IsRead = false,
                    CreatedAt = p.PaidAt ?? DateTime.UtcNow
                });
            }

            if (newNotifications.Any())
            {
                _context.Notifications.AddRange(newNotifications);
                await _context.SaveChangesAsync();
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to sync existing event notifications for manager {ManagerId}", managerId);
        }
    }

    [HttpGet("manager")]
    public async Task<IActionResult> GetManagerNotifications()
    {
        var managerId = await GetManagerUserIdAsync();

        // Auto-sync notifications for existing events/slips missing notifications
        await SyncExistingEventNotificationsAsync(managerId);

        // Fetch notifications + compute unreadCount in a single round-trip
        var allNotifications = await _context.Notifications
            .Where(n => n.UserId == managerId || n.UserId == FallbackManagerId)
            .OrderByDescending(n => n.CreatedAt)
            .Select(n => new
            {
                n.NotificationId,
                n.UserId,
                n.EventId,
                n.Title,
                n.Message,
                n.Type,
                n.IsRead,
                n.CreatedAt
            })
            .ToListAsync();

        var unreadCount = allNotifications.Count(n => !n.IsRead);
        var notifications = allNotifications.Take(50).ToList();

        return Ok(new
        {
            unreadCount,
            notifications
        });
    }

    [HttpPost("{id}/mark-read")]
    public async Task<IActionResult> MarkAsRead(Guid id)
    {
        var notification = await _context.Notifications.FindAsync(id);
        if (notification == null) return NotFound();

        notification.IsRead = true;
        await _context.SaveChangesAsync();
        return Ok(new { message = "Notification marked as read", notificationId = id });
    }

    [HttpPost("mark-all-read")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        var managerId = await GetManagerUserIdAsync();

        var unread = await _context.Notifications
            .Where(n => (n.UserId == managerId || n.UserId == FallbackManagerId) && !n.IsRead)
            .ToListAsync();

        foreach (var n in unread)
        {
            n.IsRead = true;
        }

        await _context.SaveChangesAsync();
        return Ok(new { message = "All notifications marked as read" });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteNotification(Guid id)
    {
        var notification = await _context.Notifications.FindAsync(id);
        if (notification == null) return NotFound();

        _context.Notifications.Remove(notification);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Notification deleted" });
    }
}
