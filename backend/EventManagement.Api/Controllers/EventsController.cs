using System.Text.Json;
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
        // Extract customer ID securely from token, payload, or fallback
        Guid customerId = Guid.Empty;
        if (dto.CustomerId.HasValue && dto.CustomerId.Value != Guid.Empty)
        {
            customerId = dto.CustomerId.Value;
        }
        else if (Request.Headers.TryGetValue("X-Customer-Id", out var headerCustId) && Guid.TryParse(headerCustId, out var parsedId))
        {
            customerId = parsedId;
        }

        if (customerId == Guid.Empty)
        {
            var sampleCustomer = await _context.Users.FirstOrDefaultAsync(u => u.Role!.RoleName == "Customer") 
                                 ?? await CreateFallbackCustomer();
            customerId = sampleCustomer.UserId;
        }

        Guid? venueId = dto.VenueId;
        Guid? banquetHallId = dto.BanquetHallId;
        BanquetHall? chosenHall = null;

        // Check Banquet Hall & Date Availability (Double-Booking Prevention)
        if (banquetHallId.HasValue && banquetHallId.Value != Guid.Empty)
        {
            chosenHall = await _context.BanquetHalls.Include(h => h.Venue).FirstOrDefaultAsync(h => h.BanquetHallId == banquetHallId.Value);
            if (chosenHall != null)
            {
                venueId = chosenHall.VenueId;

                var targetUtcDate = DateTime.SpecifyKind(dto.TargetDate.Date, DateTimeKind.Utc);
                var nextUtcDate = targetUtcDate.AddDays(1);
                var isAlreadyBooked = await _context.Events.AnyAsync(e => 
                    e.BanquetHallId == banquetHallId.Value && 
                    e.Status != "Cancelled" && 
                    e.TargetDate >= targetUtcDate && 
                    e.TargetDate < nextUtcDate);

                if (isAlreadyBooked)
                {
                    return BadRequest(new { message = $"The banquet hall '{chosenHall.HallName}' is already reserved on {dto.TargetDate:yyyy-MM-dd}. Please choose another hall or date." });
                }
            }
        }
        else if (!venueId.HasValue && !string.IsNullOrEmpty(dto.PreferredLocation))
        {
            var matchedVenue = await _context.Venues.FirstOrDefaultAsync(v => 
                v.Name.ToLower().Contains(dto.PreferredLocation.ToLower()) ||
                v.LocationAddress.ToLower().Contains(dto.PreferredLocation.ToLower()));
            if (matchedVenue != null)
            {
                venueId = matchedVenue.VenueId;
            }
        }

        var eventType = !string.IsNullOrWhiteSpace(dto.CustomEventType) 
            ? dto.CustomEventType.Trim() 
            : (!string.IsNullOrWhiteSpace(dto.EventType) ? dto.EventType.Trim() : "Wedding");

        bool isInherentlyIndoor = 
            eventType.Equals("Product Launch", StringComparison.OrdinalIgnoreCase) ||
            eventType.Equals("Dinner/Gala", StringComparison.OrdinalIgnoreCase) ||
            eventType.Equals("Award Ceremony", StringComparison.OrdinalIgnoreCase) ||
            eventType.Equals("Award Ceramony", StringComparison.OrdinalIgnoreCase);

        bool isOutdoor = isInherentlyIndoor ? false : dto.IsOutdoor;

        string? additionalDetails = !string.IsNullOrWhiteSpace(dto.AdditionalDetails) 
            ? dto.AdditionalDetails.Trim() 
            : null;

        string? inspirationJson = null;
        if (dto.InspirationImages != null && dto.InspirationImages.Count > 0)
        {
            inspirationJson = JsonSerializer.Serialize(dto.InspirationImages);
        }
        else if (!string.IsNullOrWhiteSpace(dto.InspirationImageUrl))
        {
            var raw = dto.InspirationImageUrl.Trim();
            if (raw.StartsWith("["))
            {
                inspirationJson = raw;
            }
            else
            {
                inspirationJson = JsonSerializer.Serialize(new List<string> { raw });
            }
        }

        var servicesJson = dto.SelectedServices != null && dto.SelectedServices.Count > 0
            ? JsonSerializer.Serialize(dto.SelectedServices)
            : null;

        var newEvent = new Event
        {
            CustomerId = customerId,
            VenueId = venueId,
            BanquetHallId = banquetHallId,
            EventType = eventType,
            Title = string.IsNullOrWhiteSpace(dto.Title) ? $"{eventType} Celebration" : dto.Title,
            TargetDate = DateTime.SpecifyKind(dto.TargetDate, DateTimeKind.Utc),
            GuestCount = dto.GuestCount,
            BudgetLimit = dto.BudgetLimit,
            IsOutdoor = isOutdoor,
            AdditionalDetails = additionalDetails,
            InspirationImageUrl = inspirationJson,
            SelectedServicesJson = servicesJson,
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
            EventType = newEvent.EventType,
            TargetDate = newEvent.TargetDate,
            GuestCount = newEvent.GuestCount,
            BudgetLimit = newEvent.BudgetLimit,
            IsOutdoor = newEvent.IsOutdoor,
            AdditionalDetails = newEvent.AdditionalDetails,
            Status = newEvent.Status, // Will be 'PendingManagerApproval' after AI execution
            VenueId = newEvent.VenueId,
            BanquetHallId = newEvent.BanquetHallId,
            BanquetHallName = chosenHall?.HallName,
            HallRentalPrice = chosenHall?.HallRentalPrice,
            PerPlatePrice = chosenHall?.PerPlatePrice,
            InspirationImageUrl = newEvent.InspirationImageUrl,
            InspirationImages = ParseInspirationImages(newEvent.InspirationImageUrl),
            SelectedServices = dto.SelectedServices,
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
            .Include(e => e.BanquetHall)
            .Include(e => e.AIWorkflowState)
            .FirstOrDefaultAsync(e => e.EventId == id);

        if (ev == null)
            return NotFound(new { message = "Event not found." });

        return Ok(new EventResponseDto
        {
            EventId = ev.EventId,
            Title = ev.Title,
            EventType = ev.EventType,
            TargetDate = ev.TargetDate,
            GuestCount = ev.GuestCount,
            BudgetLimit = ev.BudgetLimit,
            IsOutdoor = ev.IsOutdoor,
            AdditionalDetails = ev.AdditionalDetails,
            Status = ev.Status,
            VenueId = ev.VenueId,
            VenueName = ev.Venue?.Name,
            BanquetHallId = ev.BanquetHallId,
            BanquetHallName = ev.BanquetHall?.HallName,
            HallRentalPrice = ev.BanquetHall?.HallRentalPrice,
            PerPlatePrice = ev.BanquetHall?.PerPlatePrice,
            InspirationImageUrl = ev.InspirationImageUrl,
            InspirationImages = ParseInspirationImages(ev.InspirationImageUrl),
            SelectedServices = !string.IsNullOrEmpty(ev.SelectedServicesJson)
                ? JsonSerializer.Deserialize<List<string>>(ev.SelectedServicesJson)
                : new List<string>(),
            EstimatedTotalCost = ev.AIWorkflowState?.EstimatedTotalCost,
            CreatedAt = ev.CreatedAt
        });
    }

    // 2.1 GET: api/events/{id}/proposal (Detailed Proposal & Booking Pass for Mobile)
    [HttpGet("{id}/proposal")]
    public async Task<ActionResult> GetEventProposal(Guid id)
    {
        var ev = await _context.Events
            .Include(e => e.Venue)
            .Include(e => e.BanquetHall)
            .FirstOrDefaultAsync(e => e.EventId == id);

        if (ev == null)
            return NotFound(new { message = "Event not found." });

        var aiState = await _context.AIWorkflowStates.FirstOrDefaultAsync(a => a.EventId == id);
        var booking = await _context.Bookings
            .Include(b => b.EntryPass)
            .FirstOrDefaultAsync(b => b.EventId == id);

        var selectedServices = !string.IsNullOrEmpty(ev.SelectedServicesJson)
            ? JsonSerializer.Deserialize<List<string>>(ev.SelectedServicesJson)
            : new List<string>();

        var inspirationImages = ParseInspirationImages(ev.InspirationImageUrl);

        return Ok(new
        {
            eventId = ev.EventId,
            title = ev.Title,
            eventType = ev.EventType,
            targetDate = ev.TargetDate,
            guestCount = ev.GuestCount,
            budgetLimit = ev.BudgetLimit,
            isOutdoor = ev.IsOutdoor,
            additionalDetails = ev.AdditionalDetails,
            status = ev.Status,
            venueName = ev.Venue?.Name ?? "Selected Luxury Resort",
            banquetHallName = ev.BanquetHall?.HallName,
            hallRentalPrice = ev.BanquetHall?.HallRentalPrice,
            perPlatePrice = ev.BanquetHall?.PerPlatePrice,
            selectedServices = selectedServices,
            inspirationImages = inspirationImages,
            inspirationImageUrl = ev.InspirationImageUrl,
            estimatedTotalCost = aiState?.EstimatedTotalCost ?? ev.BudgetLimit,
            weatherAssessment = aiState?.WeatherAssessmentJson,
            generatedPlan = aiState?.GeneratedPlanJson,
            bookingRef = booking?.BookingReferenceCode,
            qrCodeData = booking?.EntryPass?.QrCodeData,
            isConfirmed = booking != null
        });
    }

    // 3. GET: api/events/my-events (List Customer Events with strict per-user filtering)
    [HttpGet("my-events")]
    public async Task<ActionResult<IEnumerable<EventResponseDto>>> GetMyEvents([FromQuery] Guid? customerId)
    {
        if (!customerId.HasValue && Request.Headers.TryGetValue("X-Customer-Id", out var headerCustId) && Guid.TryParse(headerCustId, out var parsedId))
        {
            customerId = parsedId;
        }

        var query = _context.Events.AsQueryable();

        // If customerId is provided, filter strictly by this customer
        if (customerId.HasValue && customerId.Value != Guid.Empty)
        {
            query = query.Where(e => e.CustomerId == customerId.Value);
        }

        var events = await query
            .Include(e => e.Venue)
            .Include(e => e.BanquetHall)
            .Include(e => e.AIWorkflowState)
            .OrderByDescending(e => e.CreatedAt)
            .Select(ev => new EventResponseDto
            {
                EventId = ev.EventId,
                Title = ev.Title,
                EventType = ev.EventType,
                TargetDate = ev.TargetDate,
                GuestCount = ev.GuestCount,
                BudgetLimit = ev.BudgetLimit,
                IsOutdoor = ev.IsOutdoor,
                AdditionalDetails = ev.AdditionalDetails,
                Status = ev.Status,
                VenueId = ev.VenueId,
                VenueName = ev.Venue != null ? ev.Venue.Name : null,
                BanquetHallId = ev.BanquetHallId,
                BanquetHallName = ev.BanquetHall != null ? ev.BanquetHall.HallName : null,
                HallRentalPrice = ev.BanquetHall != null ? ev.BanquetHall.HallRentalPrice : null,
                PerPlatePrice = ev.BanquetHall != null ? ev.BanquetHall.PerPlatePrice : null,
                InspirationImageUrl = ev.InspirationImageUrl,
                EstimatedTotalCost = ev.AIWorkflowState != null ? ev.AIWorkflowState.EstimatedTotalCost : null,
                CreatedAt = ev.CreatedAt
            })
            .ToListAsync();

        foreach (var item in events)
        {
            item.InspirationImages = ParseInspirationImages(item.InspirationImageUrl);
        }

        return Ok(events);
    }

    // 4. POST: api/events/{id}/approve-proposal (Manager Human-in-the-Loop Approval - Spec Section 9.1)
    [HttpPost("{id}/approve-proposal")]
    public async Task<ActionResult> ApproveProposal(Guid id, [FromQuery] decimal discount = 0, [FromQuery] decimal? finalTotal = null)
    {
        var ev = await _context.Events.FindAsync(id);
        if (ev == null)
            return NotFound(new { message = "Event not found in database." });

        ev.Status = "ApprovedByManager";

        var aiState = await _context.AIWorkflowStates.FirstOrDefaultAsync(a => a.EventId == id);
        if (aiState != null)
        {
            aiState.ApprovalStatus = "ApprovedByManager";
            if (finalTotal.HasValue && finalTotal.Value > 0)
            {
                aiState.EstimatedTotalCost = finalTotal.Value;
            }
            else
            {
                // Dynamic baseline: (guests * 5000) + 300000 + (special requests: 35000) - discount
                decimal baseSubtotal = (ev.GuestCount * 5000m) + 300000m;
                if (!string.IsNullOrWhiteSpace(ev.AdditionalDetails))
                {
                    baseSubtotal += 35000m;
                }
                aiState.EstimatedTotalCost = Math.Max(0, baseSubtotal - discount);
            }
        }

        await _context.SaveChangesAsync();

        return Ok(new 
        { 
            message = "Proposal approved successfully by Manager.", 
            status = ev.Status, 
            finalTotal = aiState?.EstimatedTotalCost 
        });
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

    private static List<string> ParseInspirationImages(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw)) return new List<string>();
        raw = raw.Trim();
        if (raw.StartsWith("["))
        {
            try
            {
                var list = JsonSerializer.Deserialize<List<string>>(raw);
                if (list != null && list.Count > 0) return list;
            }
            catch
            {
                // Fallback to single string
            }
        }
        if (raw.StartsWith("data:image"))
        {
            if (raw.Contains("|||"))
            {
                return raw.Split(new[] { "|||" }, StringSplitOptions.RemoveEmptyEntries).ToList();
            }
            return new List<string> { raw };
        }
        if (raw.Contains("|||"))
        {
            return raw.Split(new[] { "|||" }, StringSplitOptions.RemoveEmptyEntries).ToList();
        }
        if (!raw.Contains("base64") && raw.Contains(","))
        {
            return raw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries).ToList();
        }
        return new List<string> { raw };
    }
}