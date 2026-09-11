using System.ComponentModel.DataAnnotations;
 
namespace EventManagement.Core.Entities;
 
public class Venue : BaseEntity
{
    [Key]
    public Guid VenueId { get; set; } = Guid.NewGuid();
    [Required, MaxLength(150)]
    public string Name { get; set; } = string.Empty;
    [Required]
    public string LocationAddress { get; set; } = string.Empty;
    public int MaxCapacity { get; set; }
    public decimal BaseRentalPrice { get; set; }
    public bool IsOutdoor { get; set; }
    public string Status { get; set; } = "Available"; // Available, Maintenance
    public Guid? ManagerId { get; set; }
    public User? Manager { get; set; }
}