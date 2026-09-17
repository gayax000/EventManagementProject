using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.Entities;

public class BanquetHall : BaseEntity
{
    [Key]
    public Guid BanquetHallId { get; set; } = Guid.NewGuid();

    public Guid VenueId { get; set; }
    public Venue? Venue { get; set; }

    [Required, MaxLength(150)]
    public string HallName { get; set; } = string.Empty;

    public int MaxCapacity { get; set; }

    public decimal HallRentalPrice { get; set; }

    public decimal PerPlatePrice { get; set; } = 5000m;

    public bool IsOutdoor { get; set; }

    public string Status { get; set; } = "Available"; // Available, Maintenance
}
