using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.DTOs;

// 1. Submit Bank Slip DTO
public class SubmitPaymentSlipDto
{
    public Guid? BookingId { get; set; }
    public Guid? EventId { get; set; }

    public decimal? Amount { get; set; }

    [Range(1, 100000000, ErrorMessage = "Amount must be greater than 100.")]
    public decimal AmountPaid 
    { 
        get => _amountPaid > 0 ? _amountPaid : (Amount ?? 0); 
        set => _amountPaid = value; 
    }
    private decimal _amountPaid;

    public string? PaymentSlipUrl { get; set; }

    [Required(ErrorMessage = "The SlipImageUrl field is required.")]
    public string SlipImageUrl 
    { 
        get => !string.IsNullOrEmpty(_slipImageUrl) ? _slipImageUrl : (PaymentSlipUrl ?? string.Empty); 
        set => _slipImageUrl = value; 
    }
    private string _slipImageUrl = string.Empty;

    public string PaymentMethod { get; set; } = "BankTransferSlip";
    public string? BankReferenceNumber { get; set; }
    public string? Notes { get; set; }
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