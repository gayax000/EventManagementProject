using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using EventManagement.Infrastructure.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EventsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IAiWorkflowService _aiWorkflowService;

    public EventsController(AppDbContext context, IAiWorkflowService aiWorkflowService)
    {
        _context = context;
        _aiWorkflowService = aiWorkflowService;
    }

    // 1. POST: api/events (Create Event Request & Auto-Trigger Agentic AI)
    [HttpPost]
    public async Task<ActionResult<EventResponseDto>> CreateEvent([FromBody] CreateEventRequestDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        // Simulated Customer ID (පසුව JWT auth එකෙන් ලබා ගනී)
        var sampleCustomer = await _context.Users.FirstOrDefaultAsync(u => u.Role!.RoleName == "Customer") 
                             ?? await CreateFallbackCustomer();

        var newEvent = new Event
        {
            CustomerId = sampleCustomer.UserId,
            VenueId = dto.VenueId,
            Title = dto.Title,
            TargetDate = dto.TargetDate,
            GuestCount = dto.GuestCount,
            BudgetLimit = dto.BudgetLimit,
            InspirationImageUrl = dto.InspirationImageUrl,
            Status = "UnderReview"
        };

        _context.Events.Add(newEvent);
        await _context.SaveChangesAsync();

        // Trigger Agentic AI Workflow in background (End-to-End Spec Section 10)
        await _aiWorkflowService.TriggerAgenticPlanAsync(newEvent.EventId);

        var response = new EventResponseDto
        {
            EventId = newEvent.EventId,
            Title = newEvent.Title,
            TargetDate = newEvent.TargetDate,
            GuestCount = newEvent.GuestCount,
            BudgetLimit = newEvent.BudgetLimit,
            Status = newEvent.Status, // Will be 'PendingManagerApproval' after AI execution
            VenueId = newEvent.VenueId,
            CreatedAt = newEvent.CreatedAt
        };

        return CreatedAtAction(nameof(GetEventById), new { id = newEvent.EventId }, response);
    }

    // 2. GET: api/events/{id}
    [HttpGet("{id}")]
    public async Task<ActionResult<EventResponseDto>> GetEventById(Guid id)
    {
        var ev = await _context.Events
            .Include(e => e.Venue)
            .FirstOrDefaultAsync(e => e.EventId == id);

        if (ev == null)
            return NotFound(new { message = "Event not found." });

        return Ok(new EventResponseDto
        {
            EventId = ev.EventId,
            Title = ev.Title,
            TargetDate = ev.TargetDate,
            GuestCount = ev.GuestCount,
            BudgetLimit = ev.BudgetLimit,
            Status = ev.Status,
            VenueId = ev.VenueId,
            VenueName = ev.Venue?.Name,
            CreatedAt = ev.CreatedAt
        });
    }

    // 3. GET: api/events/my-events (List Customer Events)
    [HttpGet("my-events")]
    public async Task<ActionResult<IEnumerable<EventResponseDto>>> GetMyEvents()
    {
        var events = await _context.Events
            .Include(e => e.Venue)
            .OrderByDescending(e => e.CreatedAt)
            .Select(ev => new EventResponseDto
            {
                EventId = ev.EventId,
                Title = ev.Title,
                TargetDate = ev.TargetDate,
                GuestCount = ev.GuestCount,
                BudgetLimit = ev.BudgetLimit,
                Status = ev.Status,
                VenueId = ev.VenueId,
                VenueName = ev.Venue != null ? ev.Venue.Name : null,
                CreatedAt = ev.CreatedAt
            })
            .ToListAsync();

        return Ok(events);
    }

    // 4. POST: api/events/{id}/approve-proposal (Manager Human-in-the-Loop Approval - Spec Section 9.1)
    [HttpPost("{id}/approve-proposal")]
    public async Task<ActionResult> ApproveProposal(Guid id, [FromQuery] decimal discount = 0)
    {
        var aiState = await _context.AIWorkflowStates.Include(a => a.Event).FirstOrDefaultAsync(a => a.EventId == id);
        if (aiState == null)
            return NotFound(new { message = "AI Proposal not found for this event." });

        aiState.ApprovalStatus = "ApprovedByManager";
        if (discount > 0)
            aiState.EstimatedTotalCost -= discount;

        if (aiState.Event != null)
            aiState.Event.Status = "ApprovedByManager";

        await _context.SaveChangesAsync();

        return Ok(new { message = "Proposal approved successfully by Manager.", finalCost = aiState.EstimatedTotalCost });
    }

    // 5. POST: api/events/{id}/sign-contract (Business-Specific: Contract Sign & QR Entry Pass Generation)
    [HttpPost("{id}/sign-contract")]
    public async Task<ActionResult<BookingResponseDto>> SignContractAndConfirm(Guid id, [FromBody] SignContractRequestDto dto)
    {
        var ev = await _context.Events.FindAsync(id);
        if (ev == null)
            return NotFound(new { message = "Event not found." });

        var referenceCode = $"EV-2026-{new Random().Next(1000, 9999)}";
        var qrData = $"EVENTCRAFT|{referenceCode}|{ev.EventId}|{DateTime.UtcNow:yyyyMMdd}";

        var booking = new Booking
        {
            EventId = ev.EventId,
            BookingReferenceCode = referenceCode,
            TotalAgreedAmount = dto.AgreedTotalAmount,
            DigitalSignatureUrl = dto.DigitalSignatureUrl,
            Status = "Confirmed",
            ConfirmedAt = DateTime.UtcNow
        };

        var entryPass = new EntryPass
        {
            BookingId = booking.BookingId,
            QrCodeData = qrData,
            IsScanned = false
        };

        booking.EntryPass = entryPass;
        ev.Status = "Confirmed";

        _context.Bookings.Add(booking);
        await _context.SaveChangesAsync();

        return Ok(new BookingResponseDto
        {
            BookingId = booking.BookingId,
            EventId = booking.EventId,
            BookingReferenceCode = booking.BookingReferenceCode,
            TotalAgreedAmount = booking.TotalAgreedAmount,
            Status = booking.Status,
            QrCodeData = entryPass.QrCodeData,
            ConfirmedAt = booking.ConfirmedAt
        });
    }

    // 6. GET: api/events/verify-pass/{qrCodeData} (Device Feature: QR Code Scanner Verification)
    [HttpGet("verify-pass/{qrCodeData}")]
    public async Task<ActionResult> VerifyPass(string qrCodeData)
    {
        var pass = await _context.EntryPasses
            .Include(p => p.Booking)
            .ThenInclude(b => b!.Event)
            .FirstOrDefaultAsync(p => p.QrCodeData == qrCodeData);

        if (pass == null)
            return NotFound(new { isValid = false, message = "Invalid QR Entry Pass." });

        if (pass.IsScanned)
            return BadRequest(new { isValid = false, message = "This pass has already been used!", scannedAt = pass.ScannedAt });

        pass.IsScanned = true;
        pass.ScannedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return Ok(new
        {
            isValid = true,
            eventTitle = pass.Booking?.Event?.Title,
            bookingRef = pass.Booking?.BookingReferenceCode,
            scannedAt = pass.ScannedAt
        });
    }

    private async Task<User> CreateFallbackCustomer()
    {
        var customerRole = await _context.Roles.FirstAsync(r => r.RoleName == "Customer");
        var user = new User
        {
            FullName = "Kasun Customer",
            Email = "kasun@example.com",
            PasswordHash = "SampleHashedPass",
            RoleId = customerRole.RoleId
        };
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }
}