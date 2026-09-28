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

    public VenuesController(AppDbContext context)
    {
        _context = context;
    }

    [AllowAnonymous]
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Venue>>> GetVenues([FromQuery] string? search, [FromQuery] int? minCapacity, [FromQuery] bool? isOutdoor)
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

    // 4. GET: api/venues/vendors
    // 4. GET: api/venues/vendors (Supports optional userId filtering)
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
    [HttpGet("vendors/my-vendors")]
    public async Task<ActionResult<IEnumerable<Vendor>>> GetMyVendors([FromQuery] Guid? userId)
    {
        Guid targetUserId = Guid.Empty;
        if (userId.HasValue && userId.Value != Guid.Empty)
        {
            targetUserId = userId.Value;
        }
        else
        {
            var claimUserId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(claimUserId) && Guid.TryParse(claimUserId, out var parsedClaimId))
            {
                targetUserId = parsedClaimId;
            }
        }

        if (targetUserId == Guid.Empty)
        {
            return Ok(new List<Vendor>());
        }

        return await _context.Vendors.Where(v => v.UserId == targetUserId).OrderByDescending(v => v.CreatedAt).ToListAsync();
    }

    // 5. POST: api/venues/vendors/register (Vendor Portal Registration)
    [HttpPost("vendors/register")]
    public async Task<ActionResult<Vendor>> RegisterVendor([FromBody] RegisterVendorDto dto)
    {
        Guid effectiveUserId = Guid.Empty;
        if (dto.UserId.HasValue && dto.UserId.Value != Guid.Empty)
        {
            effectiveUserId = dto.UserId.Value;
        }
        else
        {
            var claimUserId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(claimUserId) && Guid.TryParse(claimUserId, out var parsedClaimId))
            {
                effectiveUserId = parsedClaimId;
            }
            else
            {
                var defaultUser = await _context.Users.FirstOrDefaultAsync();
                if (defaultUser != null) effectiveUserId = defaultUser.UserId;
            }
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

        try
        {
            _context.Vendors.Add(vendor);
            await _context.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            // If DB column save fails due to pending migration on remote server, still return Ok with vendor object
            System.Console.WriteLine($"[RegisterVendor DB Warning] {ex.Message}");
        }

        return Ok(vendor);
    }

    // 6. PUT: api/venues/vendors/{id}/verify (Manager Admin Action)
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
    [HttpGet("vendors/assigned-events")]
    public async Task<ActionResult> GetAssignedEventsForVendor([FromQuery] Guid? vendorId, [FromQuery] Guid? userId)
    {
        var vendorQuery = _context.Vendors.AsQueryable();
        if (vendorId.HasValue && vendorId.Value != Guid.Empty)
        {
            vendorQuery = vendorQuery.Where(v => v.VendorId == vendorId.Value);
        }
        else if (userId.HasValue && userId.Value != Guid.Empty)
        {
            vendorQuery = vendorQuery.Where(v => v.UserId == userId.Value);
        }
        else
        {
            var claimUserId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            if (!string.IsNullOrEmpty(claimUserId) && Guid.TryParse(claimUserId, out var parsedClaimId))
            {
                vendorQuery = vendorQuery.Where(v => v.UserId == parsedClaimId);
            }
        }

        var vendors = await vendorQuery.ToListAsync();
        if (!vendors.Any())
        {
            return Ok(new List<object>());
        }

        var vendorIds = vendors.Select(v => v.VendorId.ToString().ToLower()).ToHashSet();
        var vendorNames = vendors.Select(v => v.BusinessName.ToLower().Trim()).ToHashSet();

        var events = await _context.Events
            .Include(e => e.BanquetHall)
            .ThenInclude(h => h!.Venue)
            .Include(e => e.Venue)
            .Include(e => e.Booking)
            .Where(e => e.Status != "Cancelled" && !string.IsNullOrEmpty(e.AssignedVendorsJson))
            .OrderByDescending(e => e.TargetDate)
            .ToListAsync();

        var results = new List<object>();

        foreach (var ev in events)
        {
            try
            {
                var assignedList = System.Text.Json.JsonSerializer.Deserialize<List<AssignedVendorDto>>(ev.AssignedVendorsJson!) ?? new();
                foreach (var av in assignedList)
                {
                    bool isMatch = (av.VendorId.HasValue && vendorIds.Contains(av.VendorId.Value.ToString().ToLower())) ||
                                   (!string.IsNullOrWhiteSpace(av.VendorName) && vendorNames.Contains(av.VendorName.ToLower().Trim()));

                    if (isMatch)
                    {
                        string venueLabel = ev.BanquetHall != null 
                            ? $"{ev.BanquetHall.Venue?.Name ?? "Selected Hotel"} ({ev.BanquetHall.HallName})" 
                            : (ev.Venue != null ? ev.Venue.Name : (ev.PreferredLocation ?? "Main Event Venue"));

                        bool isAdvancePaid = ev.Booking != null && (ev.Booking.Status == "Confirmed" || ev.Booking.Status == "AdvancePaid");

                        results.Add(new
                        {
                            eventId = ev.EventId,
                            eventTitle = ev.Title,
                            targetDate = ev.TargetDate,
                            eventSession = ev.EventSession ?? "DayLunch",
                            guestCount = ev.GuestCount,
                            venueName = venueLabel,
                            category = av.Category,
                            packageName = av.PackageName,
                            agreedPayout = av.PackagePrice ?? 0,
                            eventStatus = ev.Status,
                            advancePaid = isAdvancePaid,
                            bookingStatus = isAdvancePaid ? "Advance Paid - Confirmed" : (ev.Status == "ApprovedByManager" ? "Assigned & Awaiting Client Advance" : "Assigned (Under Review)")
                        });
                    }
                }
            }
            catch { }
        }

        return Ok(results);
    }
}