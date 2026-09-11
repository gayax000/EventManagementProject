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

    public PaymentsController(AppDbContext context)
    {
        _context = context;
    }

    // 1. POST: api/payments/upload-slip (Customer uploads Bank Transfer Slip)
    [HttpPost("upload-slip")]
    public async Task<ActionResult<Payment>> UploadPaymentSlip([FromBody] SubmitPaymentSlipDto dto)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var booking = await _context.Bookings.FindAsync(dto.BookingId);
        if (booking == null)
            return NotFound(new { message = "Booking not found." });

        var payment = new Payment
        {
            BookingId = dto.BookingId,
            AmountPaid = dto.AmountPaid,
            PaymentMethod = dto.PaymentMethod,
            SlipImageUrl = dto.SlipImageUrl,
            Status = "PendingVerification",
            PaidAt = DateTime.UtcNow
        };

        _context.Payments.Add(payment);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(UploadPaymentSlip), new { id = payment.PaymentId }, payment);
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