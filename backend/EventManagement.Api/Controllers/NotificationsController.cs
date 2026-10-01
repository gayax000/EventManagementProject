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

    public NotificationsController(AppDbContext context)
    {
        _context = context;
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
            var existingEvents = await _context.Events.ToListAsync();
            var existingNotificationEventIds = await _context.Notifications
                .Where(n => n.EventId != null)
                .Select(n => n.EventId!.Value)
                .ToListAsync();

            var newNotifications = new List<Notification>();

            foreach (var ev in existingEvents)
            {
                if (!existingNotificationEventIds.Contains(ev.EventId))
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
            }

            var payments = await _context.Payments
                .Include(p => p.Booking)
                .Where(p => p.Status == "PendingVerification")
                .ToListAsync();

            foreach (var p in payments)
            {
                if (p.Booking?.EventId != null)
                {
                    var hasPayNotif = await _context.Notifications.AnyAsync(n => n.EventId == p.Booking.EventId && n.Type == "PaymentSlipUploaded");
                    if (!hasPayNotif)
                    {
                        newNotifications.Add(new Notification
                        {
                            UserId = managerId,
                            EventId = p.Booking.EventId,
                            Title = "💳 Payment Slip Uploaded",
                            Message = $"Payment slip of LKR {p.AmountPaid:N0} uploaded. Pending Manager Verification.",
                            Type = "PaymentSlipUploaded",
                            IsRead = false,
                            CreatedAt = p.PaidAt ?? DateTime.UtcNow
                        });
                    }
                }
            }

            if (newNotifications.Any())
            {
                _context.Notifications.AddRange(newNotifications);
                await _context.SaveChangesAsync();
            }
        }
        catch { }
    }

    [HttpGet("manager")]
    public async Task<IActionResult> GetManagerNotifications()
    {
        var managerId = await GetManagerUserIdAsync();

        // Auto-sync notifications for existing events/slips missing notifications
        await SyncExistingEventNotificationsAsync(managerId);

        var notifications = await _context.Notifications
            .Where(n => n.UserId == managerId || n.UserId == FallbackManagerId)
            .OrderByDescending(n => n.CreatedAt)
            .Take(50)
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

        var unreadCount = await _context.Notifications
            .CountAsync(n => (n.UserId == managerId || n.UserId == FallbackManagerId) && !n.IsRead);

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
