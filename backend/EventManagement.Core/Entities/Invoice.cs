using System.ComponentModel.DataAnnotations;
namespace EventManagement.Core.Entities;
public class Invoice : BaseEntity
{
    [Key]
    public Guid InvoiceId { get; set; } = Guid.NewGuid();
    
    public Guid BookingId { get; set; }
    public Booking? Booking { get; set; }
    
    [Required, MaxLength(50)]
    public string InvoiceNumber { get; set; } = string.Empty; // e.g. INV-2026-001
    
    public decimal Subtotal { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal FinalTotal { get; set; }
    public string? InvoicePdfUrl { get; set; }
    public DateTime IssuedAt { get; set; } = DateTime.UtcNow;
}