using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.Entities;

public class Event : BaseEntity
{
    [Key]
    public Guid EventId { get; set; } = Guid.NewGuid();

    public Guid CustomerId { get; set; }
    public User? Customer { get; set; }

    public Guid? VenueId { get; set; }
    public Venue? Venue { get; set; }

    public Guid? BanquetHallId { get; set; }
    public BanquetHall? BanquetHall { get; set; }

    [Required, MaxLength(100)]
    public string EventType { get; set; } = "Wedding";

    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public DateTime TargetDate { get; set; }
    public int GuestCount { get; set; }
    public decimal BudgetLimit { get; set; }
    public bool IsOutdoor { get; set; } = false;
    public string? AdditionalDetails { get; set; }
    public string? InspirationImageUrl { get; set; }

    public string? SelectedServicesJson { get; set; }

    // Draft, UnderReview, ApprovedByManager, Confirmed, Rejected, Cancelled
    public string Status { get; set; } = "UnderReview";

    public Booking? Booking { get; set; }
    public AIWorkflowState? AIWorkflowState { get; set; }
}