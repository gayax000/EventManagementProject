using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BanquetHallsController : ControllerBase
{
    private readonly AppDbContext _context;

    public BanquetHallsController(AppDbContext context)
    {
        _context = context;
    }

    // 1. GET: api/banquethalls?venueId=...&date=...
    [HttpGet]
    public async Task<ActionResult<IEnumerable<BanquetHallDto>>> GetBanquetHalls([FromQuery] Guid? venueId, [FromQuery] DateTime? date)
    {
        var query = _context.BanquetHalls.Include(h => h.Venue).AsQueryable();

        if (venueId.HasValue && venueId.Value != Guid.Empty)
        {
            query = query.Where(h => h.VenueId == venueId.Value);
        }

        var halls = await query.ToListAsync();

        // If target date is provided, check which halls are already booked on that date
        HashSet<Guid> bookedHallIds = new();
        if (date.HasValue)
        {
            var targetUtcDate = DateTime.SpecifyKind(date.Value.Date, DateTimeKind.Utc);
            var nextUtcDate = targetUtcDate.AddDays(1);

            var booked = await _context.Events
                .Where(e => e.BanquetHallId.HasValue && 
                            e.Status != "Cancelled" && 
                            e.TargetDate >= targetUtcDate && 
                            e.TargetDate < nextUtcDate)
                .Select(e => e.BanquetHallId!.Value)
                .ToListAsync();

            bookedHallIds = new HashSet<Guid>(booked);
        }

        var dtos = halls.Select(h => new BanquetHallDto
        {
            BanquetHallId = h.BanquetHallId,
            VenueId = h.VenueId,
            VenueName = h.Venue?.Name ?? "Selected Hotel",
            HallName = h.HallName,
            MaxCapacity = h.MaxCapacity,
            HallRentalPrice = h.HallRentalPrice,
            PerPlatePrice = h.PerPlatePrice,
            IsOutdoor = h.IsOutdoor,
            IsAvailable = !bookedHallIds.Contains(h.BanquetHallId)
        }).ToList();

        return Ok(dtos);
    }

    // 2. GET: api/banquethalls/{id}/check-availability?date=...
    [HttpGet("{id}/check-availability")]
    public async Task<ActionResult> CheckAvailability(Guid id, [FromQuery] DateTime date)
    {
        var targetUtcDate = DateTime.SpecifyKind(date.Date, DateTimeKind.Utc);
        var nextUtcDate = targetUtcDate.AddDays(1);

        var isBooked = await _context.Events
            .AnyAsync(e => e.BanquetHallId == id && 
                           e.Status != "Cancelled" && 
                           e.TargetDate >= targetUtcDate && 
                           e.TargetDate < nextUtcDate);

        return Ok(new
        {
            banquetHallId = id,
            date = targetUtcDate,
            isAvailable = !isBooked,
            message = isBooked ? "This hall is already booked on the selected date." : "Hall is available."
        });
    }
}
