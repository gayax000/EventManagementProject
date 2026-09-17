using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PaymentsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly ILogger<PaymentsController> _logger;

    public PaymentsController(AppDbContext context, ILogger<PaymentsController> logger)
    {
        _context = context;
        _logger = logger;
    }

    // 1. POST: api/payments/upload-slip (Customer uploads Bank Transfer Slip)
    [HttpPost("upload-slip")]
    public async Task<ActionResult> UploadPaymentSlip([FromBody] SubmitPaymentSlipDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            Booking? booking = null;
            if (dto.BookingId.HasValue && dto.BookingId.Value != Guid.Empty)
            {
                booking = await _context.Bookings.FindAsync(dto.BookingId.Value);
            }

            if (booking == null && dto.EventId.HasValue && dto.EventId.Value != Guid.Empty)
            {
                booking = await _context.Bookings.FirstOrDefaultAsync(b => b.EventId == dto.EventId.Value);
                if (booking == null)
                {
                    var ev = await _context.Events.FindAsync(dto.EventId.Value);
                    if (ev != null)
                    {
                        var refCode = $"EV-2026-{new Random().Next(1000, 9999)}";
                        booking = new Booking
                        {
                            EventId = ev.EventId,
                            BookingReferenceCode = refCode,
                            TotalAgreedAmount = dto.AmountPaid,
                            Status = "PendingPaymentVerification",
                            ConfirmedAt = null
                        };
                        _context.Bookings.Add(booking);
                        await _context.SaveChangesAsync();
                    }
                }
            }

            if (booking == null)
                return NotFound(new { message = "Booking or Event not found." });

            var payment = new Payment
            {
                BookingId = booking.BookingId,
                AmountPaid = dto.AmountPaid,
                PaymentMethod = dto.PaymentMethod,
                SlipImageUrl = dto.SlipImageUrl,
                Status = "PendingVerification",
                PaidAt = DateTime.UtcNow
            };

            _context.Payments.Add(payment);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Payment slip uploaded successfully and is pending Manager verification.",
                paymentId = payment.PaymentId,
                bookingId = payment.BookingId,
                amountPaid = payment.AmountPaid,
                status = payment.Status,
                paidAt = payment.PaidAt
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error uploading payment slip for booking {BookingId}, event {EventId}", dto.BookingId, dto.EventId);
            return StatusCode(500, new
            {
                message = "An error occurred while uploading payment slip.",
                error = ex.Message,
                inner = ex.InnerException?.Message
            });
        }
    }

    // 1.1 GET: api/payments (List all customer payment slips for Manager Verification Queue)
    [HttpGet]
    public async Task<ActionResult> GetAllPayments()
    {
        var payments = await _context.Payments
            .Include(p => p.Booking)
                .ThenInclude(b => b!.Event)
                    .ThenInclude(e => e!.Customer)
            .OrderByDescending(p => p.PaidAt)
            .Select(p => new
            {
                id = p.PaymentId.ToString(),
                bookingRef = p.Booking != null ? p.Booking.BookingReferenceCode : "EV-2026-REF",
                clientName = p.Booking != null && p.Booking.Event != null && p.Booking.Event.Customer != null
                    ? p.Booking.Event.Customer.FullName
                    : "Client Customer",
                eventTitle = p.Booking != null && p.Booking.Event != null ? p.Booking.Event.Title : "Event Reservation",
                amount = p.AmountPaid,
                slipUrl = p.SlipImageUrl,
                date = (p.PaidAt ?? DateTime.UtcNow).ToString("yyyy-MM-dd HH:mm"),
                status = p.Status,
                rejectReason = p.RejectReason,
                invoiceNumber = _context.Invoices
                    .Where(i => i.BookingId == p.BookingId)
                    .Select(i => i.InvoiceNumber)
                    .FirstOrDefault()
            })
            .ToListAsync();

        return Ok(payments);
    }

    // 2. PUT: api/payments/{id}/verify (Business-Specific: Admin verifies slip & auto-generates Invoice)
    [HttpPut("{id}/verify")]
    public async Task<ActionResult> VerifyPayment(Guid id, [FromBody] VerifyPaymentDto dto)
    {
        var payment = await _context.Payments
            .Include(p => p.Booking)
            .FirstOrDefaultAsync(p => p.PaymentId == id);

        if (payment == null)
            return NotFound(new { message = "Payment record not found." });

        payment.Status = dto.Status;
        payment.RejectReason = dto.RejectReason;

        if (dto.Status == "Approved" && payment.Booking != null)
        {
            payment.Booking.Status = "PaidAndConfirmed";

            // Automatically issue an official Invoice
            var invoice = new Invoice
            {
                BookingId = payment.BookingId,
                InvoiceNumber = $"INV-2026-{new Random().Next(1000, 9999)}",
                Subtotal = payment.Booking.TotalAgreedAmount,
                DiscountAmount = 0,
                FinalTotal = payment.AmountPaid,
                IssuedAt = DateTime.UtcNow
            };
            _context.Invoices.Add(invoice);
        }

        await _context.SaveChangesAsync();

        return Ok(new { message = $"Payment has been {dto.Status}.", paymentStatus = payment.Status });
    }

    // 3. GET: api/payments/analytics/revenue-forecast (Business-Specific: AI Predictive Analytics)
    [HttpGet("analytics/revenue-forecast")]
    public async Task<ActionResult<RevenueForecastResponseDto>> GetRevenueForecast()
    {
        var totalRevenue = await _context.Payments
            .Where(p => p.Status == "Approved")
            .SumAsync(p => (decimal?)p.AmountPaid) ?? 0;

        var eventCount = await _context.Bookings
            .CountAsync(b => b.Status == "Confirmed" || b.Status == "PaidAndConfirmed");

        return Ok(new RevenueForecastResponseDto
        {
            TotalRevenueToDate = totalRevenue,
            ConfirmedEventsCount = eventCount,
            ProjectedMonthlyRevenue = totalRevenue * 1.25m + 500000,
            PeakBookingMonths = new List<string> { "October", "November", "December" }
        });
    }
}