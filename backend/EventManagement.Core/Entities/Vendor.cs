using System.ComponentModel.DataAnnotations;
 
namespace EventManagement.Core.Entities;
 
public class Vendor : BaseEntity
{
    [Key]
    public Guid VendorId { get; set; } = Guid.NewGuid();
    public Guid UserId { get; set; }
    public User? User { get; set; }
    [Required, MaxLength(150)]
    public string BusinessName { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty; // Catering, AudioVisual, Marquee
    public string ContactNumber { get; set; } = string.Empty;
    public string VerificationStatus { get; set; } = "Pending"; // Pending, Verified, Rejected
    public string? AdminRemarks { get; set; }
}
 