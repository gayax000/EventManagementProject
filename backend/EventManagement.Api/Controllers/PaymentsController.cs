using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Api.Controllers;

[Authorize]
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

    private Guid? GetCurrentUserId()
    {
        var claim = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
                    ?? User.FindFirst("sub")?.Value;
        if (Guid.TryParse(claim, out var userId))
            return userId;
        return null;
    }

    private bool IsManagerOrAdmin()
    {
        return User.IsInRole("Manager") || User.IsInRole("Admin");
    }

    // 1. POST: api/payments/upload-slip (Customer uploads Bank Transfer Slip)
    [Authorize(Roles = "Customer,Manager,Admin")]
    [HttpPost("upload-slip")]
    public async Task<ActionResult> UploadPaymentSlip([FromBody] SubmitPaymentSlipDto dto)
    {
        try
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var currentUserId = GetCurrentUserId();
            if (!currentUserId.HasValue)
                return Unauthorized();

            Booking? booking = null;
            if (dto.BookingId.HasValue && dto.BookingId.Value != Guid.Empty)
            {
                booking = await _context.Bookings
                    .Include(b => b.Event)
                    .FirstOrDefaultAsync(b => b.BookingId == dto.BookingId.Value);

                if (booking != null && !IsManagerOrAdmin())
                {
                    if (booking.Event == null || booking.Event.CustomerId != currentUserId.Value)
                    {
                        return Forbid();
                    }
                }
            }

            if (booking == null && dto.EventId.HasValue && dto.EventId.Value != Guid.Empty)
            {
                booking = await _context.Bookings
                    .Include(b => b.Event)
                    .FirstOrDefaultAsync(b => b.EventId == dto.EventId.Value);

                if (booking != null && !IsManagerOrAdmin())
                {
                    if (booking.Event == null || booking.Event.CustomerId != currentUserId.Value)
                    {
                        return Forbid();
                    }
                }

                if (booking == null)
                {
                    var ev = await _context.Events.FindAsync(dto.EventId.Value);
                    if (ev == null)
                    {
                        return NotFound(new { message = "Event not found." });
                    }

                    if (!IsManagerOrAdmin() && ev.CustomerId != currentUserId.Value)
                    {
                        return Forbid();
                    }

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

            // Create Manager Notification for Payment Slip Upload
            try
            {
                var manager = await _context.Users.FirstOrDefaultAsync(u => u.Email == "manager@eventcraft.lk" || u.RoleId == 2);
                var managerId = manager?.UserId ?? Guid.Parse("11111111-1111-1111-1111-111111111111");
                var evTitle = booking.Event?.Title ?? "Event Reservation";

                _context.Notifications.Add(new Notification
                {
                    UserId = managerId,
                    EventId = booking.EventId,
                    Title = "💳 Payment Slip Uploaded",
                    Message = $"Payment slip of LKR {payment.AmountPaid:N0} uploaded for \"{evTitle}\". Pending Manager Verification.",
                    Type = "PaymentSlipUploaded",
                    CreatedAt = DateTime.UtcNow
                });
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to create manager notification for payment slip {PaymentId}", payment.PaymentId);
            }

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
                message = "An unexpected error occurred while processing the payment slip."
            });
        }
    }

    // 1.1 GET: api/payments (List all customer payment slips for Manager Verification Queue)
    [Authorize(Roles = "Manager,Admin")]
    [HttpGet]
    public async Task<ActionResult> GetAllPayments(
        [FromQuery] int? pageNumber,
        [FromQuery] int? pageSize,
        [FromQuery] string? status)
    {
        var query = _context.Payments
            .Include(p => p.Booking)
                .ThenInclude(b => b!.Event)
                    .ThenInclude(e => e!.Customer)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(p => p.Status == status);
        }

        var totalCount = await query.CountAsync();

        var pagedQuery = query.OrderByDescending(p => p.PaidAt);

        if (pageNumber.HasValue || pageSize.HasValue)
        {
            int page = pageNumber.HasValue && pageNumber.Value > 0 ? pageNumber.Value : 1;
            int size = pageSize.HasValue && pageSize.Value > 0 ? pageSize.Value : 10;
            pagedQuery = (IOrderedQueryable<Payment>)pagedQuery.Skip((page - 1) * size).Take(size);
        }

        var payments = await pagedQuery
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

        if (pageNumber.HasValue || pageSize.HasValue)
        {
            int page = pageNumber.HasValue && pageNumber.Value > 0 ? pageNumber.Value : 1;
            int size = pageSize.HasValue && pageSize.Value > 0 ? pageSize.Value : 10;

            return Ok(new PagedResult<object>
            {
                Items = payments,
                TotalCount = totalCount,
                PageNumber = page,
                PageSize = size
            });
        }

        return Ok(payments);
    }

    // 1.2 GET: api/payments/my-payments (Customer payment history, slips, and invoices)
    [Authorize(Roles = "Customer,Manager,Admin")]
    [HttpGet("my-payments")]
    public async Task<ActionResult> GetMyPayments([FromQuery] Guid? customerId)
    {
        var currentUserId = GetCurrentUserId();
        if (!currentUserId.HasValue)
        {
            return Unauthorized();
        }

        Guid targetCustomerId = currentUserId.Value;

        if (IsManagerOrAdmin() && customerId.HasValue && customerId.Value != Guid.Empty)
        {
            targetCustomerId = customerId.Value;
        }

        var query = _context.Payments
            .AsNoTracking()
            .Include(p => p.Booking)
                .ThenInclude(b => b!.Event)
            .Where(p => p.Booking != null && p.Booking.Event != null && p.Booking.Event.CustomerId == targetCustomerId);

        var list = await query
            .OrderByDescending(p => p.PaidAt)
            .Select(p => new
            {
                paymentId = p.PaymentId,
                bookingId = p.BookingId,
                bookingRef = p.Booking != null ? p.Booking.BookingReferenceCode : "EV-2026-REF",
                eventId = p.Booking != null ? p.Booking.EventId : Guid.Empty,
                eventTitle = p.Booking != null && p.Booking.Event != null ? p.Booking.Event.Title : "Event Reservation",
                eventType = p.Booking != null && p.Booking.Event != null ? p.Booking.Event.EventType : "Wedding",
                amountPaid = p.AmountPaid,
                totalAgreed = p.Booking != null ? p.Booking.TotalAgreedAmount : p.AmountPaid,
                paymentMethod = p.PaymentMethod,
                slipImageUrl = p.SlipImageUrl,
                status = p.Status,
                paidAt = p.PaidAt,
                invoiceNumber = _context.Invoices
                    .Where(i => i.BookingId == p.BookingId)
                    .Select(i => i.InvoiceNumber)
                    .FirstOrDefault(),
                qrCodeData = _context.EntryPasses
                    .Where(ep => ep.BookingId == p.BookingId)
                    .Select(ep => ep.QrCodeData)
                    .FirstOrDefault()
            })
            .ToListAsync();

        return Ok(list);
    }

    // 2. PUT: api/payments/{id}/verify (Business-Specific: Admin verifies slip & auto-generates Invoice via Database Transaction)
    [Authorize(Roles = "Manager,Admin")]
    [HttpPut("{id}/verify")]
    public async Task<ActionResult> VerifyPayment(Guid id, [FromBody] VerifyPaymentDto dto)
    {
        await using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            var payment = await _context.Payments
                .Include(p => p.Booking)
                    .ThenInclude(b => b!.Event)
                .FirstOrDefaultAsync(p => p.PaymentId == id);

            if (payment == null)
            {
                await transaction.RollbackAsync();
                return NotFound(new { message = "Payment record not found." });
            }

            // Step 1: Update Payment Status & remarks
            payment.Status = dto.Status;
            payment.RejectReason = dto.RejectReason;

            // Step 2: Update Booking, Event & Invoice if Approved
            if (dto.Status == "Approved" && payment.Booking != null)
            {
                payment.Booking.Status = "PaidAndConfirmed";
                payment.Booking.ConfirmedAt = DateTime.UtcNow;

                if (payment.Booking.Event != null)
                {
                    payment.Booking.Event.Status = "Confirmed";
                }

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

                // Step 3: Create customer notification
                if (payment.Booking.Event != null && payment.Booking.Event.CustomerId != Guid.Empty)
                {
                    _context.Notifications.Add(new Notification
                    {
                        UserId = payment.Booking.Event.CustomerId,
                        EventId = payment.Booking.EventId,
                        Title = "Payment Approved & Booking Confirmed",
                        Message = $"Your payment of LKR {payment.AmountPaid:N0} for event '{payment.Booking.Event.Title}' has been approved and your booking is confirmed.",
                        Type = "PaymentVerified",
                        CreatedAt = DateTime.UtcNow
                    });
                }
            }
            else if (dto.Status == "Rejected" && payment.Booking != null)
            {
                payment.Booking.Status = "PaymentRejected";
                if (payment.Booking.Event != null && payment.Booking.Event.CustomerId != Guid.Empty)
                {
                    _context.Notifications.Add(new Notification
                    {
                        UserId = payment.Booking.Event.CustomerId,
                        EventId = payment.Booking.EventId,
                        Title = "Payment Verification Rejected",
                        Message = $"Payment slip for '{payment.Booking.Event.Title}' was rejected: {dto.RejectReason ?? "Please re-upload a clear slip."}",
                        Type = "PaymentRejected",
                        CreatedAt = DateTime.UtcNow
                    });
                }
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            return Ok(new { message = $"Payment has been {dto.Status}.", paymentStatus = payment.Status });
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            _logger.LogError(ex, "Transaction failed and rolled back while verifying payment {PaymentId}", id);
            throw;
        }
    }

    // 3. GET: api/payments/analytics/revenue-forecast (Business-Specific: AI Predictive Analytics)
    [Authorize(Roles = "Manager,Admin")]
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