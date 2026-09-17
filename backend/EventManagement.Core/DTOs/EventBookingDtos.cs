using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.DTOs;

// 1. Create Event Request DTO
public class CreateEventRequestDto
{
    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    public DateTime TargetDate { get; set; }

    [Range(1, 10000, ErrorMessage = "Guest count must be at least 1.")]
    public int GuestCount { get; set; }

    [Range(1000, 100000000, ErrorMessage = "Budget limit must be valid.")]
    public decimal BudgetLimit { get; set; }

    public Guid? VenueId { get; set; }
    public string? InspirationImageUrl { get; set; }
    public Guid? CustomerId { get; set; }
    public string? PreferredLocation { get; set; }
}

// 2. Event Response DTO
public class EventResponseDto
{
    public Guid EventId { get; set; }
    public string Title { get; set; } = string.Empty;
    public DateTime TargetDate { get; set; }
    public int GuestCount { get; set; }
    public decimal BudgetLimit { get; set; }
    public string Status { get; set; } = string.Empty;
    public Guid? VenueId { get; set; }
    public string? VenueName { get; set; }
    public decimal? EstimatedTotalCost { get; set; }
    public DateTime CreatedAt { get; set; }
}

// 3. Digital Contract Sign DTO (Business-specific operation)
public class SignContractRequestDto
{
    [Required]
    public string DigitalSignatureUrl { get; set; } = string.Empty;

    [Range(1, 100000000)]
    public decimal AgreedTotalAmount { get; set; }
}

// 4. Booking & QR Pass Response DTO
public class BookingResponseDto
{
    public Guid BookingId { get; set; }
    public Guid EventId { get; set; }
    public string BookingReferenceCode { get; set; } = string.Empty;
    public decimal TotalAgreedAmount { get; set; }
    public string Status { get; set; } = string.Empty;
    public string QrCodeData { get; set; } = string.Empty;
    public DateTime? ConfirmedAt { get; set; }
}