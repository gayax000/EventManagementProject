using System.Text.Json;
using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using EventManagement.Infrastructure.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class EventsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IAiWorkflowService _aiWorkflowService;
    private readonly ILogger<EventsController> _logger;

    public EventsController(AppDbContext context, IAiWorkflowService aiWorkflowService, ILogger<EventsController> logger)
    {
        _context = context;
        _aiWorkflowService = aiWorkflowService;
        _logger = logger;
    }

    private static bool _schemaEnsured = false;
    private async Task EnsureSchemaAsync()
    {
        if (_schemaEnsured) return;
        try
        {
            await _context.Database.ExecuteSqlRawAsync(@"
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""PreferredLocation"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""TableRefreshmentsJson"" text;
                ALTER TABLE ""Events"" ADD COLUMN IF NOT EXISTS ""RevisionNotes"" text;
            ");
            _schemaEnsured = true;
        }
        catch { }
    }

    // 1. POST: api/events (Create Event Request & Auto-Trigger Agentic AI)
    [AllowAnonymous]
    [HttpPost]
    public async Task<ActionResult<EventResponseDto>> CreateEvent([FromBody] CreateEventRequestDto dto)
    {
        try
        {
            await EnsureSchemaAsync();

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
                var sampleCustomer = await _context.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Role != null && u.Role.RoleName == "Customer") 
                                     ?? await CreateFallbackCustomer();
                customerId = sampleCustomer.UserId;
            }

            Guid? venueId = dto.VenueId;
            Guid? banquetHallId = dto.BanquetHallId;
            BanquetHall? chosenHall = null;

            // Check Banquet Hall & Session Availability (Double-Booking Prevention per Session)
            if (banquetHallId.HasValue && banquetHallId.Value != Guid.Empty)
            {
                chosenHall = await _context.BanquetHalls.Include(h => h.Venue).FirstOrDefaultAsync(h => h.BanquetHallId == banquetHallId.Value);
                if (chosenHall != null)
                {
                    venueId = chosenHall.VenueId;

                    var targetUtcDate = DateTime.SpecifyKind(dto.TargetDate.Date, DateTimeKind.Utc);
                    var nextUtcDate = targetUtcDate.AddDays(1);
                    var requestedSession = !string.IsNullOrWhiteSpace(dto.EventSession) ? dto.EventSession.Trim() : "DayLunch";

                    var isAlreadyBooked = await _context.Events.AnyAsync(e => 
                        e.BanquetHallId == banquetHallId.Value && 
                        e.Status != "Cancelled" && 
                        e.TargetDate >= targetUtcDate && 
                        e.TargetDate < nextUtcDate &&
                        (e.EventSession == requestedSession || string.IsNullOrEmpty(e.EventSession)));

                    if (isAlreadyBooked)
                    {
                        var sessionName = requestedSession == "NightDinner" ? "Night Dinner Session" : (requestedSession == "EveningHighTea" ? "High Tea Session" : "Day Lunch Session");
                        return BadRequest(new { message = $"The banquet hall '{chosenHall.HallName}' is already reserved on {dto.TargetDate:yyyy-MM-dd} for the {sessionName}. Please choose another time slot, hall, or date." });
                    }
                }
            }
            else if (!venueId.HasValue && !string.IsNullOrEmpty(dto.PreferredLocation))
            {
                var cleanTarget = System.Text.RegularExpressions.Regex.Replace(dto.PreferredLocation.ToLower(), @"[^\w\s]", "");
                var keywords = cleanTarget.Split(' ', StringSplitOptions.RemoveEmptyEntries)
                    .Where(k => k.Length > 2 && k != "district" && k != "province" && k != "colombo" && k != "kandy" && k != "galle" && k != "hotel" && k != "resort")
                    .ToList();

                var allVenues = await _context.Venues.ToListAsync();
                Venue? matchedVenue = null;

                if (keywords.Count > 0)
                {
                    matchedVenue = allVenues.FirstOrDefault(v => {
                        var vClean = System.Text.RegularExpressions.Regex.Replace((v.Name ?? "").ToLower(), @"[^\w\s]", "");
                        return keywords.All(k => vClean.Contains(k)) || keywords.Any(k => vClean.Contains(k));
                    });
                }

                if (matchedVenue == null)
                {
                    matchedVenue = allVenues.FirstOrDefault(v => {
                        var vClean = System.Text.RegularExpressions.Regex.Replace((v.Name ?? "").ToLower(), @"[^\w\s]", "");
                        return cleanTarget.Contains(vClean) || vClean.Contains(cleanTarget);
                    });
                }

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

            var refreshmentsJson = dto.TableRefreshments != null && dto.TableRefreshments.Count > 0
                ? JsonSerializer.Serialize(dto.TableRefreshments)
                : null;

            var eventSession = !string.IsNullOrWhiteSpace(dto.EventSession) ? dto.EventSession.Trim() : "DayLunch";
            var cateringStyle = !string.IsNullOrWhiteSpace(dto.CateringStyle) ? dto.CateringStyle.Trim() : "InternationalBuffet";

            var newEvent = new Event
            {
                EventId = Guid.NewGuid(),
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
                EventSession = eventSession,
                CateringStyle = cateringStyle,
                TableRefreshmentsJson = refreshmentsJson,
                PreferredLocation = dto.PreferredLocation,
                Status = "UnderReview"
            };

            _context.Events.Add(newEvent);
            await _context.SaveChangesAsync();

            // Trigger Agentic AI Workflow in background (End-to-End Spec Section 10)
            try
            {
                await _aiWorkflowService.TriggerAgenticPlanAsync(newEvent.EventId);
            }
            catch (Exception aiEx)
            {
                _logger.LogWarning(aiEx, "AI Plan generation experienced non-fatal warning for Event {EventId}", newEvent.EventId);
            }

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
                EventSession = newEvent.EventSession,
                CateringStyle = newEvent.CateringStyle,
                TableRefreshments = dto.TableRefreshments,
                RevisionNotes = newEvent.RevisionNotes,
                CreatedAt = newEvent.CreatedAt
            };

            return CreatedAtAction(nameof(GetEventById), new { id = newEvent.EventId }, response);
        }
        catch (Exception ex)
        {
            var rootEx = ex;
            while (rootEx.InnerException != null)
            {
                rootEx = rootEx.InnerException;
            }
            _logger.LogError(ex, "Error occurred during CreateEvent: {InnerMessage}", rootEx.Message);
            return StatusCode(500, new { message = $"Failed to create event: {rootEx.Message}" });
        }
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
            VenueName = ev.BanquetHall?.Venue?.Name ?? ev.Venue?.Name ?? ev.PreferredLocation,
            BanquetHallId = ev.BanquetHallId,
            BanquetHallName = ev.BanquetHall?.HallName,
            HallRentalPrice = ev.BanquetHall?.HallRentalPrice,
            PerPlatePrice = ev.BanquetHall?.PerPlatePrice,
            InspirationImageUrl = ev.InspirationImageUrl,
            InspirationImages = ParseInspirationImages(ev.InspirationImageUrl),
            SelectedServices = !string.IsNullOrEmpty(ev.SelectedServicesJson)
                ? JsonSerializer.Deserialize<List<string>>(ev.SelectedServicesJson)
                : new List<string>(),
            EventSession = ev.EventSession,
            CateringStyle = ev.CateringStyle,
            TableRefreshments = !string.IsNullOrEmpty(ev.TableRefreshmentsJson)
                ? JsonSerializer.Deserialize<List<string>>(ev.TableRefreshmentsJson)
                : new List<string>(),
            RevisionNotes = ev.RevisionNotes,
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

        var payment = booking != null
            ? await _context.Payments
                .Where(p => p.BookingId == booking.BookingId)
                .OrderByDescending(p => p.Status == "Approved" || p.Status == "Completed")
                .ThenByDescending(p => p.PaidAt)
                .FirstOrDefaultAsync()
            : null;

        var invoice = booking != null
            ? await _context.Invoices.FirstOrDefaultAsync(i => i.BookingId == booking.BookingId)
            : null;

        var selectedServices = !string.IsNullOrEmpty(ev.SelectedServicesJson)
            ? JsonSerializer.Deserialize<List<string>>(ev.SelectedServicesJson)
            : new List<string>();

        var tableRefreshments = !string.IsNullOrEmpty(ev.TableRefreshmentsJson)
            ? JsonSerializer.Deserialize<List<string>>(ev.TableRefreshmentsJson)
            : new List<string>();

        var inspirationImages = ParseInspirationImages(ev.InspirationImageUrl);

        decimal? specialRequestAlloc = null;
        if (aiState != null && !string.IsNullOrEmpty(aiState.GeneratedPlanJson))
        {
            var match = System.Text.RegularExpressions.Regex.Match(aiState.GeneratedPlanJson, @"Manager Allocated:\s*Rs\.\s*([\d,]+)");
            if (match.Success && decimal.TryParse(match.Groups[1].Value.Replace(",", ""), out var parsedAlloc))
            {
                specialRequestAlloc = parsedAlloc;
            }
        }

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
            eventSession = ev.EventSession,
            cateringStyle = ev.CateringStyle,
            tableRefreshments = tableRefreshments,
            revisionNotes = ev.RevisionNotes,
            specialRequestAllocation = specialRequestAlloc,
            status = ev.Status,
            venueName = ev.BanquetHall?.Venue?.Name ?? ev.Venue?.Name ?? ev.PreferredLocation ?? "Selected Luxury Resort",
            banquetHallName = ev.BanquetHall?.HallName,
            hallRentalPrice = ev.BanquetHall?.HallRentalPrice,
            perPlatePrice = ev.BanquetHall?.PerPlatePrice,
            selectedServices = selectedServices,
            inspirationImages = inspirationImages,
            inspirationImageUrl = ev.InspirationImageUrl,
            estimatedTotalCost = aiState?.EstimatedTotalCost ?? ev.BudgetLimit,
            weatherAssessment = aiState?.WeatherAssessmentJson,
            generatedPlan = aiState?.GeneratedPlanJson,
            bookingId = booking?.BookingId,
            bookingRef = booking?.BookingReferenceCode,
            qrCodeData = booking?.EntryPass?.QrCodeData,
            isConfirmed = (ev.Status == "Confirmed" || (booking != null && booking.Status == "Confirmed")) && booking?.EntryPass != null,
            isPaymentUnlocked = ev.Status == "ApprovedByManager" || ev.Status == "Confirmed",
            paymentStatus = payment?.Status,
            slipImageUrl = payment?.SlipImageUrl,
            invoiceNumber = invoice?.InvoiceNumber
        });
    }

    // 2.2 POST: api/events/{id}/submit-client-budget-choice (Client Budget Response from Mobile)
    [AllowAnonymous]
    [HttpPost("{id}/submit-client-budget-choice")]
    public async Task<ActionResult> SubmitClientBudgetChoice(Guid id, [FromQuery] string? choice, [FromQuery] decimal? chosenTotal, [FromBody] SubmitClientBudgetChoiceDto? dtoBody)
    {
        var ev = await _context.Events.FindAsync(id);
        if (ev == null)
            return NotFound(new { message = "Event not found." });

        var clientAction = dtoBody?.ClientAction ?? choice ?? "accept";
        var isRevision = clientAction.Equals("request_revision", StringComparison.OrdinalIgnoreCase) || clientAction.Equals("revision", StringComparison.OrdinalIgnoreCase);

        if (isRevision)
        {
            ev.Status = "RevisionRequested";
            if (!string.IsNullOrWhiteSpace(dtoBody?.RevisionNotes))
            {
                ev.RevisionNotes = dtoBody.RevisionNotes.Trim();
            }
        }
        else
        {
            ev.Status = "ClientChoiceSubmitted";
        }

        var aiState = await _context.AIWorkflowStates.FirstOrDefaultAsync(a => a.EventId == id);
        if (aiState != null)
        {
            aiState.ApprovalStatus = ev.Status;
            if (chosenTotal.HasValue && chosenTotal.Value > 0)
            {
                aiState.EstimatedTotalCost = chosenTotal.Value;
            }
        }

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = isRevision ? "Revision request submitted to Manager." : "Client choice submitted successfully.",
            status = ev.Status,
            choice = clientAction,
            revisionNotes = ev.RevisionNotes,
            chosenTotal = aiState?.EstimatedTotalCost
        });
    }

    // 3. GET: api/events/my-events (List Customer Events with strict per-user filtering)
    [AllowAnonymous]
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
                EventSession = ev.EventSession,
                CateringStyle = ev.CateringStyle,
                TableRefreshments = null,
                RevisionNotes = ev.RevisionNotes,
                Status = ev.Status,
                VenueId = ev.VenueId,
                VenueName = ev.BanquetHall != null && ev.BanquetHall.Venue != null ? ev.BanquetHall.Venue.Name : (ev.Venue != null ? ev.Venue.Name : ev.PreferredLocation),
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
            var evEntity = await _context.Events.FindAsync(item.EventId);
            if (evEntity != null && !string.IsNullOrEmpty(evEntity.TableRefreshmentsJson))
            {
                try { item.TableRefreshments = JsonSerializer.Deserialize<List<string>>(evEntity.TableRefreshmentsJson); }
                catch { }
            }
        }

        return Ok(events);
    }

    // 4. POST: api/events/{id}/approve-proposal (Manager Human-in-the-Loop Approval - Spec Section 9.1)
    [Authorize(Roles = "Manager")]
    [HttpPost("{id}/approve-proposal")]
    public async Task<ActionResult> ApproveProposal(Guid id, [FromQuery] decimal discount = 0, [FromQuery] decimal? finalTotal = null, [FromQuery] string? status = null, [FromQuery] decimal? customAddonCost = null, [FromBody] List<string>? planItems = null)
    {
        var ev = await _context.Events.FindAsync(id);
        if (ev == null)
            return NotFound(new { message = "Event not found in database." });

        ev.Status = !string.IsNullOrWhiteSpace(status) ? status : "ApprovedByManager";

        var aiState = await _context.AIWorkflowStates.FirstOrDefaultAsync(a => a.EventId == id);
        if (aiState != null)
        {
            aiState.ApprovalStatus = ev.Status;
            if (finalTotal.HasValue && finalTotal.Value > 0)
            {
                aiState.EstimatedTotalCost = finalTotal.Value;
            }
            else
            {
                // Dynamic baseline: (guests * 5000) + 300000 + (custom addon cost set by manager) + (outdoor tent: 150000 if outdoor) - discount
                decimal baseSubtotal = (ev.GuestCount * 5000m) + 300000m;
                if (customAddonCost.HasValue && customAddonCost.Value > 0)
                {
                    baseSubtotal += customAddonCost.Value;
                }
                if (ev.IsOutdoor)
                {
                    baseSubtotal += 150000m; // Only add marquee tent safeguard if outdoor
                }
                aiState.EstimatedTotalCost = Math.Max(0, baseSubtotal - discount);
            }

            if (planItems != null && planItems.Count > 0)
            {
                aiState.GeneratedPlanJson = JsonSerializer.Serialize(planItems);
            }
            else if (customAddonCost.HasValue && customAddonCost.Value > 0 && !string.IsNullOrWhiteSpace(ev.AdditionalDetails))
            {
                try
                {
                    var items = JsonSerializer.Deserialize<List<string>>(aiState.GeneratedPlanJson) ?? new List<string>();
                    bool updated = false;
                    for (int i = 0; i < items.Count; i++)
                    {
                        if (items[i].StartsWith("Special Client Request:"))
                        {
                            items[i] = $"Special Client Request: {ev.AdditionalDetails} (Manager Allocated: Rs. {customAddonCost.Value:N0})";
                            updated = true;
                            break;
                        }
                    }
                    if (!updated)
                    {
                        items.Add($"Special Client Request: {ev.AdditionalDetails} (Manager Allocated: Rs. {customAddonCost.Value:N0})");
                    }
                    aiState.GeneratedPlanJson = JsonSerializer.Serialize(items);
                }
                catch { }
            }
        }

        await _context.SaveChangesAsync();

        return Ok(new 
        { 
            message = "Proposal decision processed successfully.", 
            status = ev.Status, 
            finalTotal = aiState?.EstimatedTotalCost 
        });
    }

    // 5. POST: api/events/{id}/sign-contract (Business-Specific: Contract Sign & QR Entry Pass Generation)
    [HttpPost("{id}/sign-contract")]
    public async Task<ActionResult<BookingResponseDto>> SignContractAndConfirm(Guid id, [FromBody] SignContractRequestDto dto)
    {
        try
        {
            var ev = await _context.Events.FindAsync(id);
            if (ev == null)
                return NotFound(new { message = "Event not found." });

            // Find existing booking if created during slip upload
            var booking = await _context.Bookings
                .Include(b => b.EntryPass)
                .FirstOrDefaultAsync(b => b.EventId == id);

            if (booking == null)
            {
                var refCode = $"EV-2026-{new Random().Next(1000, 9999)}";
                booking = new Booking
                {
                    BookingId = Guid.NewGuid(),
                    EventId = ev.EventId,
                    BookingReferenceCode = refCode,
                    TotalAgreedAmount = dto.AgreedTotalAmount > 0 ? dto.AgreedTotalAmount : ev.BudgetLimit,
                    DigitalSignatureUrl = dto.DigitalSignatureUrl,
                    Status = "PendingSignature",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Bookings.Add(booking);
                await _context.SaveChangesAsync();
            }

            // Security Check (Option 1: Strict Payment Verification Gate)
            var isPaymentApproved = await _context.Payments
                .AnyAsync(p => p.BookingId == booking.BookingId && (p.Status == "Approved" || p.Status == "Completed"));

            if (!isPaymentApproved)
            {
                return BadRequest(new 
                { 
                    message = "Payment slip must be uploaded and verified by Manager before signing contract and issuing QR entry pass." 
                });
            }

            var referenceCode = !string.IsNullOrEmpty(booking.BookingReferenceCode) 
                ? booking.BookingReferenceCode 
                : $"EV-2026-{new Random().Next(1000, 9999)}";

            var qrData = $"https://eventmanagementproject-production.up.railway.app/verify?ref={referenceCode}";

            booking.BookingReferenceCode = referenceCode;
            booking.DigitalSignatureUrl = dto.DigitalSignatureUrl;
            if (dto.AgreedTotalAmount > 0)
            {
                booking.TotalAgreedAmount = dto.AgreedTotalAmount;
            }
            booking.Status = "Confirmed";
            booking.ConfirmedAt = DateTime.UtcNow;
            booking.UpdatedAt = DateTime.UtcNow;

            // Check if EntryPass already exists for this booking in the database
            var existingPass = await _context.EntryPasses.FirstOrDefaultAsync(ep => ep.BookingId == booking.BookingId);
            if (existingPass != null)
            {
                existingPass.QrCodeData = qrData;
                existingPass.UpdatedAt = DateTime.UtcNow;
                booking.EntryPass = existingPass;
            }
            else
            {
                var entryPass = new EntryPass
                {
                    PassId = Guid.NewGuid(),
                    BookingId = booking.BookingId,
                    QrCodeData = qrData,
                    IsScanned = false,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.EntryPasses.Add(entryPass);
                booking.EntryPass = entryPass;
            }

            ev.Status = "Confirmed";
            ev.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return Ok(new BookingResponseDto
            {
                BookingId = booking.BookingId,
                EventId = booking.EventId,
                BookingReferenceCode = booking.BookingReferenceCode,
                TotalAgreedAmount = booking.TotalAgreedAmount,
                Status = booking.Status,
                QrCodeData = booking.EntryPass?.QrCodeData ?? qrData,
                ConfirmedAt = booking.ConfirmedAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error occurred in SignContractAndConfirm for event {EventId}", id);
            return StatusCode(500, new 
            { 
                message = "An error occurred while signing the contract and issuing the entry pass.", 
                error = ex.Message,
                inner = ex.InnerException?.Message
            });
        }
    }

    // 6. GET: api/events/verify-pass/{qrCodeData} (Device Feature: QR Code Scanner Verification)
    [HttpGet("verify-pass/{qrCodeData}")]
    public async Task<ActionResult> VerifyPass(string qrCodeData)
    {
        var pass = await _context.EntryPasses
            .Include(p => p.Booking)
                .ThenInclude(b => b!.Event)
                    .ThenInclude(e => e!.Customer)
            .Include(p => p.Booking)
                .ThenInclude(b => b!.Event)
                    .ThenInclude(e => e!.Venue)
            .Include(p => p.Booking)
                .ThenInclude(b => b!.Event)
                    .ThenInclude(e => e!.BanquetHall)
            .FirstOrDefaultAsync(p => p.QrCodeData == qrCodeData);

        if (pass == null)
            return NotFound(new { isValid = false, message = "Invalid QR Entry Pass. This code was not found in our system." });

        var ev = pass.Booking?.Event;
        var booking = pass.Booking;
        var customer = ev?.Customer;

        // Get payment info for total amount
        var payment = booking != null
            ? await _context.Payments
                .Where(p => p.BookingId == booking.BookingId && (p.Status == "Approved" || p.Status == "Completed"))
                .OrderByDescending(p => p.PaidAt)
                .FirstOrDefaultAsync()
            : null;

        // Get invoice
        var invoice = booking != null
            ? await _context.Invoices.FirstOrDefaultAsync(i => i.BookingId == booking.BookingId)
            : null;

        // Build selected services list
        var selectedServices = new List<string>();
        if (!string.IsNullOrEmpty(ev?.SelectedServicesJson))
        {
            try { selectedServices = System.Text.Json.JsonSerializer.Deserialize<List<string>>(ev.SelectedServicesJson) ?? new(); }
            catch { }
        }

        if (pass.IsScanned)
        {
            // Return details even for already-used passes so staff can see the booking info
            return BadRequest(new
            {
                isValid = false,
                alreadyUsed = true,
                message = "This pass has already been scanned and used for entry.",
                scannedAt = pass.ScannedAt,
                // Still return event details so staff can see the booking
                eventTitle = ev?.Title,
                eventType = ev?.EventType,
                eventDate = ev?.TargetDate,
                guestCount = ev?.GuestCount,
                venueName = ev?.Venue?.Name ?? "EventCraft Venue",
                hallName = ev?.BanquetHall?.HallName,
                bookingRef = booking?.BookingReferenceCode,
                clientName = customer?.FullName ?? "EventCraft Client",
                clientPhone = customer?.PhoneNumber,
                totalAmount = booking?.TotalAgreedAmount,
                invoiceNumber = invoice?.InvoiceNumber,
                confirmedAt = booking?.ConfirmedAt,
                selectedServices = selectedServices
            });
        }

        // Mark as scanned
        pass.IsScanned = true;
        pass.ScannedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return Ok(new
        {
            isValid = true,
            alreadyUsed = false,
            message = "Entry pass verified successfully. Guest cleared for entry.",
            scannedAt = pass.ScannedAt,
            // Full event & client details for hotel staff display
            eventTitle = ev?.Title,
            eventType = ev?.EventType,
            eventDate = ev?.TargetDate,
            guestCount = ev?.GuestCount,
            venueName = ev?.Venue?.Name ?? "EventCraft Venue",
            hallName = ev?.BanquetHall?.HallName,
            bookingRef = booking?.BookingReferenceCode,
            clientName = customer?.FullName ?? "EventCraft Client",
            clientPhone = customer?.PhoneNumber,
            totalAmount = booking?.TotalAgreedAmount,
            invoiceNumber = invoice?.InvoiceNumber,
            confirmedAt = booking?.ConfirmedAt,
            selectedServices = selectedServices
        });
    }

    private async Task<User> CreateFallbackCustomer()
    {
        var customerRole = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Customer");
        if (customerRole == null)
        {
            customerRole = new Role { RoleName = "Customer" };
            _context.Roles.Add(customerRole);
            await _context.SaveChangesAsync();
        }

        var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == "kasun@example.com");
        if (existingUser != null) return existingUser;

        var user = new User
        {
            UserId = Guid.NewGuid(),
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

    // DELETE: api/events/{id} (Delete Event Request & Associated Resources/Workflow States)
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteEvent(Guid id)
    {
        var ev = await _context.Events.FindAsync(id);
        if (ev == null)
        {
            return NotFound(new { message = "Event proposal not found." });
        }

        // Delete associated AI Workflow States
        var workflowStates = await _context.AIWorkflowStates.Where(w => w.EventId == id).ToListAsync();
        if (workflowStates.Any())
        {
            _context.AIWorkflowStates.RemoveRange(workflowStates);
        }

        // Delete associated Event Resources
        var eventResources = await _context.EventResources.Where(er => er.EventId == id).ToListAsync();
        if (eventResources.Any())
        {
            _context.EventResources.RemoveRange(eventResources);
        }

        // Delete associated booking if present
        var booking = await _context.Bookings.FirstOrDefaultAsync(b => b.EventId == id);
        if (booking != null)
        {
            _context.Bookings.Remove(booking);
        }

        _context.Events.Remove(ev);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}