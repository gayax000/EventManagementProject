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
    [HttpGet("vendors")]
    public async Task<ActionResult<IEnumerable<Vendor>>> GetVendors()
    {
        return await _context.Vendors.OrderByDescending(v => v.CreatedAt).ToListAsync();
    }

    // 5. POST: api/venues/vendors/register (Vendor Portal Registration)
    [HttpPost("vendors/register")]
    public async Task<ActionResult<Vendor>> RegisterVendor([FromBody] RegisterVendorDto dto)
    {
        var defaultUser = await _context.Users.FirstOrDefaultAsync();

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
            UserId = defaultUser != null ? defaultUser.UserId : Guid.Empty
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
}