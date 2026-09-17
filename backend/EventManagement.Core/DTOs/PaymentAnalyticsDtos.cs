using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.DTOs;

// 1. Submit Bank Slip DTO
public class SubmitPaymentSlipDto
{
    public Guid? BookingId { get; set; }
    public Guid? EventId { get; set; }

    [Range(100, 100000000, ErrorMessage = "Amount must be greater than 100.")]
    public decimal AmountPaid { get; set; }

    [Required]
    public string SlipImageUrl { get; set; } = string.Empty;

    public string PaymentMethod { get; set; } = "BankTransferSlip";
}

// 2. Admin Verify Payment DTO (Business-Specific Operation)
public class VerifyPaymentDto
{
    [Required]
    public string Status { get; set; } = "Approved"; // Approved or Rejected

    public string? RejectReason { get; set; }
}

// 3. AI Predictive Analytics Response DTO
public class RevenueForecastResponseDto
{
    public decimal ProjectedMonthlyRevenue { get; set; }
    public List<string> PeakBookingMonths { get; set; } = new();
    public decimal TotalRevenueToDate { get; set; }
    public int ConfirmedEventsCount { get; set; }
}