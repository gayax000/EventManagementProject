using System.ComponentModel.DataAnnotations;
namespace EventManagement.Core.Entities;
public class Payment : BaseEntity
{
    [Key]
    public Guid PaymentId { get; set; } = Guid.NewGuid();
    
    public Guid BookingId { get; set; }
    public Booking? Booking { get; set; }
    
    public decimal AmountPaid { get; set; }
    public string PaymentMethod { get; set; } = "BankTransferSlip"; // BankTransferSlip, OnlineSandbox
    public string? SlipImageUrl { get; set; }
    
    // PendingVerification, Approved, Rejected
    public string Status { get; set; } = "PendingVerification";
    
    public Guid? VerifiedByAdminId { get; set; }
    public User? VerifiedByAdmin { get; set; }
    public string? RejectReason { get; set; }
    public DateTime? PaidAt { get; set; }
}