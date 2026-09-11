using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.Entities;

public class Booking : BaseEntity
{
    [Key]
    public Guid BookingId { get; set; } = Guid.NewGuid();

    public Guid EventId { get; set; }
    public Event? Event { get; set; }

    [Required, MaxLength(50)]
    public string BookingReferenceCode { get; set; } = string.Empty;

    public decimal TotalAgreedAmount { get; set; }
    public string? DigitalSignatureUrl { get; set; }

    // PendingSignature, Confirmed, Completed, Cancelled
    public string Status { get; set; } = "PendingSignature";

    public DateTime? ConfirmedAt { get; set; }
    public EntryPass? EntryPass { get; set; }
    public ICollection<Payment> Payments { get; set; } = new List<Payment>();
}