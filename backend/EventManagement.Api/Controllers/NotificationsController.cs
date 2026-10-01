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

    // Helper method to resolve manager user ID
    private async Task<Guid?> GetManagerUserIdAsync()
    {
        var manager = await _context.Users.FirstOrDefaultAsync(u => u.Email == "manager@eventcraft.lk" || u.RoleId == 2);
        return manager?.UserId;
    }

    [HttpGet("manager")]
    public async Task<IActionResult> GetManagerNotifications()
    {
        var managerId = await GetManagerUserIdAsync();
        if (managerId == null)
            return Ok(new List<object>());

        var notifications = await _context.Notifications
            .Where(n => n.UserId == managerId.Value)
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
            .CountAsync(n => n.UserId == managerId.Value && !n.IsRead);

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
        if (managerId == null) return Ok();

        var unread = await _context.Notifications
            .Where(n => n.UserId == managerId.Value && !n.IsRead)
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
