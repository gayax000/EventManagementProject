using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.Entities;

public class Resource : BaseEntity
{
    [Key]
    public Guid ResourceId { get; set; } = Guid.NewGuid();
    
    public Guid? VendorId { get; set; }
    public Vendor? Vendor { get; set; }
    
    [Required, MaxLength(150)]
    public string ResourceName { get; set; } = string.Empty;
    
    public string ResourceType { get; set; } = string.Empty; // CateringPackage, SoundLighting, MarqueeTent
    public decimal UnitPrice { get; set; }
    public int AvailableQuantity { get; set; }
}