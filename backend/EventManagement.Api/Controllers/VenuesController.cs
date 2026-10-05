using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class VenuesController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ILogger<VenuesController> _logger;

    public VenuesController(AppDbContext context, ILogger<VenuesController> logger)
    {
        _context = context;
        _logger = logger;
    }

    [AllowAnonymous]
    [HttpGet]
    public async Task<ActionResult> GetVenues(
        [FromQuery] string? search, 
        [FromQuery] int? minCapacity, 
        [FromQuery] bool? isOutdoor,
        [FromQuery] int? pageNumber,
        [FromQuery] int? pageSize)
    {
        var query = _context.Venues.AsQueryable();

        if (!string.IsNullOrEmpty(search))
        {
            var searchTerm = $"%{search}%";
            query = query.Where(v => EF.Functions.ILike(v.Name, searchTerm) || EF.Functions.ILike(v.LocationAddress, searchTerm));
        }

        if (minCapacity.HasValue)
            query = query.Where(v => v.MaxCapacity >= minCapacity.Value);

        if (isOutdoor.HasValue)
            query = query.Where(v => v.IsOutdoor == isOutdoor.Value);

        query = query.OrderBy(v => v.Name);

        if (pageNumber.HasValue || pageSize.HasValue)
        {
            int page = pageNumber.HasValue && pageNumber.Value > 0 ? pageNumber.Value : 1;
            int size = pageSize.HasValue && pageSize.Value > 0 ? pageSize.Value : 10;
            int totalCount = await query.CountAsync();
            var items = await query.Skip((page - 1) * size).Take(size).ToListAsync();

            return Ok(new PagedResult<Venue>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = page,
                PageSize = size
            });
        }

        return Ok(await query.ToListAsync());
    }

    [Authorize(Roles = "Manager")]
    [HttpPost]
    public async Task<ActionResult<Venue>> CreateVenue([FromBody] CreateVenueDto dto)
    {
        var venue = new Venue
        {
            Name = dto.Name,
            LocationAddress = dto.LocationAddress,
            MaxCapacity = dto.MaxCapacity,
            BaseRentalPrice = dto.BaseRentalPrice,
            IsOutdoor = dto.IsOutdoor
        };

        _context.Venues.Add(venue);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetVenues), new { id = venue.VenueId }, venue);
    }

    private Guid? GetCurrentUserId()
    {
        var claim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                 ?? User.FindFirst("sub")?.Value;
        if (!string.IsNullOrEmpty(claim) && Guid.TryParse(claim, out var parsed))
            return parsed;
        return null;
    }

    private bool IsManagerOrAdmin()
    {
        var role = User.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value
                ?? User.FindFirst("role")?.Value;
        return string.Equals(role, "Manager", StringComparison.OrdinalIgnoreCase) ||
               string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) ||
               User.IsInRole("Manager") || User.IsInRole("Admin");
    }

    // 4. GET: api/venues/vendors (Supports optional userId filtering for Manager/Admin)
    [HttpGet("vendors")]
    public async Task<ActionResult<IEnumerable<Vendor>>> GetVendors([FromQuery] Guid? userId)
    {
        var query = _context.Vendors.AsQueryable();
        if (userId.HasValue && userId.Value != Guid.Empty)
        {
            query = query.Where(v => v.UserId == userId.Value);
        }
        return await query.OrderByDescending(v => v.CreatedAt).ToListAsync();
    }

    // 4b. GET: api/venues/vendors/my-vendors
    [Authorize(Roles = "Vendor,Manager,Admin")]
    [HttpGet("vendors/my-vendors")]
    public async Task<ActionResult<IEnumerable<Vendor>>> GetMyVendors([FromQuery] Guid? userId)
    {
        var currentUserId = GetCurrentUserId();
        if (!currentUserId.HasValue)
        {
            return Unauthorized(new { message = "User identity could not be verified from JWT token claims." });
        }

        Guid targetUserId;
        if (IsManagerOrAdmin())
        {
            targetUserId = (userId.HasValue && userId.Value != Guid.Empty) ? userId.Value : currentUserId.Value;
        }
        else
        {
            // For Vendor: ALWAYS use JWT user ID only. Ignore supplied userId completely.
            targetUserId = currentUserId.Value;
        }

        return await _context.Vendors.Where(v => v.UserId == targetUserId).OrderByDescending(v => v.CreatedAt).ToListAsync();
    }

    // 5. POST: api/venues/vendors/register (Vendor Portal Registration)
    [Authorize(Roles = "Vendor,Manager,Admin")]
    [HttpPost("vendors/register")]
    public async Task<ActionResult<Vendor>> RegisterVendor([FromBody] RegisterVendorDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (!currentUserId.HasValue)
        {
            return Unauthorized(new { message = "User identity could not be verified from JWT token claims." });
        }

        Guid effectiveUserId;
        if (IsManagerOrAdmin() && dto.UserId.HasValue && dto.UserId.Value != Guid.Empty)
        {
            effectiveUserId = dto.UserId.Value;
        }
        else
        {
            // For Vendor: UserId MUST come from JWT only.
            effectiveUserId = currentUserId.Value;
        }

        var vendor = new Vendor
        {
            VendorId = Guid.NewGuid(),
            BusinessName = dto.BusinessName,
            Category = dto.Category,
            ContactNumber = dto.ContactNumber,
            VerificationStatus = "Pending",
            AdminRemarks = dto.Description,
            PackageName = dto.PackageName ?? dto.Description,
            PackagePrice = dto.PackagePrice,
            UserId = effectiveUserId
        };

        _context.Vendors.Add(vendor);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetVendors), new { userId = vendor.UserId }, vendor);
    }

    // 6. PUT: api/venues/vendors/{id}/verify (Manager Admin Action)
    [Authorize(Roles = "Manager,Admin")]
    [HttpPut("vendors/{id}/verify")]
    public async Task<ActionResult> VerifyVendor(Guid id, [FromBody] VerifyVendorDto dto)
    {
        var vendor = await _context.Vendors.FindAsync(id);
        if (vendor == null)
            return NotFound(new { message = "Vendor not found." });

        vendor.VerificationStatus = dto.Status;
        vendor.AdminRemarks = dto.AdminRemarks;
        await _context.SaveChangesAsync();

        return Ok(new { message = $"Vendor status updated to {dto.Status} successfully." });
    }

    // 7. DELETE: api/venues/vendors/{id} (Manager Delete Action)
    [Authorize(Roles = "Manager,Admin")]
    [HttpDelete("vendors/{id}")]
    public async Task<ActionResult> DeleteVendor(Guid id)
    {
        var vendor = await _context.Vendors.FindAsync(id);
        if (vendor == null)
            return NotFound(new { message = "Vendor not found." });

        _context.Vendors.Remove(vendor);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Vendor deleted successfully." });
    }

    // 8. GET: api/venues/vendors/assigned-events (Vendor Portal View for Assigned Work Orders)
    [Authorize(Roles = "Vendor,Manager,Admin")]
    [HttpGet("vendors/assigned-events")]
    public async Task<ActionResult> GetAssignedEventsForVendor([FromQuery] Guid? vendorId, [FromQuery] Guid? userId)
    {
        var currentUserId = GetCurrentUserId();
        if (!currentUserId.HasValue)
        {
            return Unauthorized(new { message = "User identity could not be verified from JWT token claims." });
        }

        var vendorQuery = _context.Vendors.AsNoTracking().AsQueryable();

        if (IsManagerOrAdmin())
        {
            if (vendorId.HasValue && vendorId.Value != Guid.Empty && userId.HasValue && userId.Value != Guid.Empty)
            {
                vendorQuery = vendorQuery.Where(v => v.VendorId == vendorId.Value || v.UserId == userId.Value);
            }
            else if (vendorId.HasValue && vendorId.Value != Guid.Empty)
            {
                vendorQuery = vendorQuery.Where(v => v.VendorId == vendorId.Value);
            }
            else if (userId.HasValue && userId.Value != Guid.Empty)
            {
                vendorQuery = vendorQuery.Where(v => v.UserId == userId.Value);
            }
        }
        else
        {
            // For Vendor: Ignore query vendorId and userId, derive vendor identity strictly from JWT to prevent IDOR
            vendorQuery = vendorQuery.Where(v => v.UserId == currentUserId.Value);
        }

        var vendors = await vendorQuery.ToListAsync();
        if (!vendors.Any())
        {
            return Ok(new List<object>());
        }

        var vendorIds = vendors.Select(v => v.VendorId.ToString().ToLower()).ToHashSet();
        var vendorNames = vendors.Select(v => v.BusinessName.ToLower().Trim()).ToHashSet();

        var events = await _context.Events
            .AsNoTracking()
            .Include(e => e.BanquetHall)
            .ThenInclude(h => h!.Venue)
            .Include(e => e.Venue)
            .Include(e => e.Booking)
            .Include(e => e.AIWorkflowState)
            .Where(e => e.Status != "Cancelled" && (
                !string.IsNullOrEmpty(e.AssignedVendorsJson) ||
                e.Status == "ApprovedByManager" ||
                e.Status == "ClientChoiceSubmitted" ||
                e.Status == "PendingClientBudgetApproval" ||
                e.Status == "Confirmed" ||
                e.Status == "Completed"))
            .OrderByDescending(e => e.CreatedAt)
            .ToListAsync();

        var jsonOptions = new System.Text.Json.JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        var results = new List<object>();

        string FormatSessionLabel(string? session) => session switch
        {
            "NightDinner" => "Night Dinner (6:00 PM - 11:30 PM)",
            "EveningHighTea" => "Evening High Tea (3:30 PM - 7:00 PM)",
            "FullDay" => "Full Day Event",
            _ => "Day Lunch (10:00 AM - 3:30 PM)"
        };

        string FormatBookingStatus(string? evStatus, bool isAdvancePaid)
        {
            if (isAdvancePaid || evStatus == "Confirmed") return "Advance Paid - Confirmed";
            if (evStatus == "ClientChoiceSubmitted") return "Client Agreed to Proposal (Booked)";
            if (evStatus == "ApprovedByManager") return "Approved by Manager (Booked)";
            if (evStatus == "PendingClientBudgetApproval") return "Assigned (Awaiting Client Confirmation)";
            return "Allocated in Event Proposal";
        }

        string BuildNotificationMessage(string vendorBusiness, string evTitle, DateTime targetDate, string sessionLabel, string venueLabel, string pkgName, decimal payout, string? evStatus, bool isAdvancePaid)
        {
            string dateStr = targetDate.ToString("MMM dd, yyyy");
            if (isAdvancePaid || evStatus == "Confirmed")
                return $"Confirmed Work Order: '{vendorBusiness}' is officially booked (Advance Paid) for event '{evTitle}' on {dateStr} ({sessionLabel}) at {venueLabel}. Package: {pkgName} (Rs. {payout:N0}).";
            if (evStatus == "ClientChoiceSubmitted")
                return $"Client Confirmed Proposal: The client has agreed to the proposal for '{evTitle}' on {dateStr} ({sessionLabel}) at {venueLabel} with your '{pkgName}' package (Rs. {payout:N0}).";
            if (evStatus == "ApprovedByManager")
                return $"Manager Approved Booking: '{vendorBusiness}' has been approved by the Operations Manager for '{evTitle}' on {dateStr} ({sessionLabel}) at {venueLabel}. Package: {pkgName} (Rs. {payout:N0}).";
            return $"New Event Assignment: '{vendorBusiness}' has been allocated for '{evTitle}' on {dateStr} ({sessionLabel}) at {venueLabel} with package '{pkgName}' (Rs. {payout:N0}).";
        }

        foreach (var ev in events)
        {
            string venueLabel = ev.BanquetHall != null 
                ? $"{ev.BanquetHall.Venue?.Name ?? "Selected Hotel"} ({ev.BanquetHall.HallName})" 
                : (ev.Venue != null ? ev.Venue.Name : (ev.PreferredLocation ?? "Main Event Venue"));

            bool isAdvancePaid = ev.Booking != null && (ev.Booking.Status == "Confirmed" || ev.Booking.Status == "AdvancePaid");
            string sessionLabel = FormatSessionLabel(ev.EventSession);
            bool matchedForEvent = false;

            if (!string.IsNullOrWhiteSpace(ev.AssignedVendorsJson))
            {
                try
                {
                    var assignedList = System.Text.Json.JsonSerializer.Deserialize<List<AssignedVendorDto>>(ev.AssignedVendorsJson!, jsonOptions) ?? new();
                    foreach (var av in assignedList)
                    {
                        bool isMatch = (av.VendorId.HasValue && vendorIds.Contains(av.VendorId.Value.ToString().ToLower())) ||
                                       (!string.IsNullOrWhiteSpace(av.VendorName) && vendorNames.Contains(av.VendorName.ToLower().Trim()));

                        if (isMatch)
                        {
                            matchedForEvent = true;
                            var matchedVendor = vendors.FirstOrDefault(v =>
                                (av.VendorId.HasValue && v.VendorId == av.VendorId.Value) ||
                                (!string.IsNullOrWhiteSpace(av.VendorName) && string.Equals(v.BusinessName.Trim(), av.VendorName.Trim(), StringComparison.OrdinalIgnoreCase))) ?? vendors.First();

                            string pkgName = !string.IsNullOrWhiteSpace(av.PackageName) ? av.PackageName : (matchedVendor.PackageName ?? "Standard Event Package");
                            decimal payout = av.PackagePrice ?? matchedVendor.PackagePrice ?? 0m;

                            results.Add(new
                            {
                                eventId = ev.EventId,
                                eventTitle = ev.Title,
                                eventType = ev.EventType ?? "Celebration",
                                targetDate = ev.TargetDate,
                                eventSession = ev.EventSession ?? "DayLunch",
                                sessionLabel = sessionLabel,
                                guestCount = ev.GuestCount,
                                venueName = venueLabel,
                                vendorName = matchedVendor.BusinessName,
                                category = !string.IsNullOrWhiteSpace(av.Category) ? av.Category : matchedVendor.Category,
                                packageName = pkgName,
                                agreedPayout = payout,
                                eventStatus = ev.Status,
                                advancePaid = isAdvancePaid,
                                bookingStatus = FormatBookingStatus(ev.Status, isAdvancePaid),
                                notificationMessage = BuildNotificationMessage(matchedVendor.BusinessName, ev.Title, ev.TargetDate, sessionLabel, venueLabel, pkgName, payout, ev.Status, isAdvancePaid)
                            });
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to parse AssignedVendorsJson for event {EventId}", ev.EventId);
                }
            }

            // Fallback: Check AIWorkflowState.GeneratedPlanJson for [Partner: <VendorName>] or matching PackageName if AssignedVendorsJson did not already match
            if (!matchedForEvent && ev.AIWorkflowState != null && !string.IsNullOrWhiteSpace(ev.AIWorkflowState.GeneratedPlanJson))
            {
                try
                {
                    var planLines = System.Text.Json.JsonSerializer.Deserialize<List<string>>(ev.AIWorkflowState.GeneratedPlanJson, jsonOptions) ?? new();
                    var matchedVendorIdsInPlan = new HashSet<Guid>();

                    foreach (var line in planLines)
                    {
                        Vendor? matchedVendor = null;
                        string pkgName = "";
                        decimal payout = 0m;

                        var partnerMatch = System.Text.RegularExpressions.Regex.Match(line, @"^(.*?)\s*\[Partner:\s*([^\]]+)\]", System.Text.RegularExpressions.RegexOptions.IgnoreCase);
                        if (partnerMatch.Success)
                        {
                            string extractedPkg = partnerMatch.Groups[1].Value.Trim();
                            string extractedPartner = partnerMatch.Groups[2].Value.Trim();

                            matchedVendor = vendors.FirstOrDefault(v =>
                                string.Equals(v.BusinessName.Trim(), extractedPartner, StringComparison.OrdinalIgnoreCase) ||
                                (!string.IsNullOrWhiteSpace(v.PackageName) && string.Equals(v.PackageName.Trim(), extractedPkg, StringComparison.OrdinalIgnoreCase)));

                            if (matchedVendor != null)
                            {
                                payout = matchedVendor.PackagePrice ?? 0m;
                                var priceMatch = System.Text.RegularExpressions.Regex.Match(line, @"\(Rs\.\s*([\d,]+)\)");
                                if (priceMatch.Success && decimal.TryParse(priceMatch.Groups[1].Value.Replace(",", ""), out var parsedPrice) && parsedPrice > 0)
                                {
                                    payout = parsedPrice;
                                }
                                pkgName = !string.IsNullOrWhiteSpace(extractedPkg) ? extractedPkg : (matchedVendor.PackageName ?? "Standard Event Package");
                            }
                        }
                        else
                        {
                            // Also match if the plan line starts with or contains the vendor's exact PackageName or BusinessName
                            matchedVendor = vendors.FirstOrDefault(v =>
                                (!string.IsNullOrWhiteSpace(v.PackageName) && v.PackageName.Trim().Length > 6 && line.Contains(v.PackageName.Trim(), StringComparison.OrdinalIgnoreCase)) ||
                                (!string.IsNullOrWhiteSpace(v.BusinessName) && v.BusinessName.Trim().Length > 5 && line.Contains(v.BusinessName.Trim(), StringComparison.OrdinalIgnoreCase)));

                            if (matchedVendor != null)
                            {
                                payout = matchedVendor.PackagePrice ?? 0m;
                                var priceMatch = System.Text.RegularExpressions.Regex.Match(line, @"\(Rs\.\s*([\d,]+)\)");
                                if (priceMatch.Success && decimal.TryParse(priceMatch.Groups[1].Value.Replace(",", ""), out var parsedLinePrice) && parsedLinePrice > 0)
                                {
                                    payout = parsedLinePrice;
                                }
                                pkgName = matchedVendor.PackageName ?? "Standard Event Package";
                            }
                        }

                        if (matchedVendor != null && !matchedVendorIdsInPlan.Contains(matchedVendor.VendorId))
                        {
                            matchedVendorIdsInPlan.Add(matchedVendor.VendorId);
                            results.Add(new
                            {
                                eventId = ev.EventId,
                                eventTitle = ev.Title,
                                eventType = ev.EventType ?? "Celebration",
                                targetDate = ev.TargetDate,
                                eventSession = ev.EventSession ?? "DayLunch",
                                sessionLabel = sessionLabel,
                                guestCount = ev.GuestCount,
                                venueName = venueLabel,
                                vendorName = matchedVendor.BusinessName,
                                category = matchedVendor.Category,
                                packageName = pkgName,
                                agreedPayout = payout,
                                eventStatus = ev.Status,
                                advancePaid = isAdvancePaid,
                                bookingStatus = FormatBookingStatus(ev.Status, isAdvancePaid),
                                notificationMessage = BuildNotificationMessage(matchedVendor.BusinessName, ev.Title, ev.TargetDate, sessionLabel, venueLabel, pkgName, payout, ev.Status, isAdvancePaid)
                            });
                        }
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to parse GeneratedPlanJson for event {EventId}", ev.EventId);
                }
            }
        }

        return Ok(results);
    }
}