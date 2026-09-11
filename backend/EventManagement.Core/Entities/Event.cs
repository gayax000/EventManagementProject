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

    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public DateTime TargetDate { get; set; }
    public int GuestCount { get; set; }
    public decimal BudgetLimit { get; set; }
    public string? InspirationImageUrl { get; set; }

    // Draft, UnderReview, Approved, Rejected, Cancelled
    public string Status { get; set; } = "UnderReview";

    public Booking? Booking { get; set; }
    public AIWorkflowState? AIWorkflowState { get; set; }
}