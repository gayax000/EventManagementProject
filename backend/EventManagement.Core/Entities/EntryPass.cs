using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.Entities;

public class EntryPass : BaseEntity
{
    [Key]
    public Guid PassId { get; set; } = Guid.NewGuid();

    public Guid BookingId { get; set; }
    public Booking? Booking { get; set; }

    [Required]
    public string QrCodeData { get; set; } = string.Empty;
    public string? PassPdfUrl { get; set; }

    public bool IsScanned { get; set; } = false;
    public DateTime? ScannedAt { get; set; }
}