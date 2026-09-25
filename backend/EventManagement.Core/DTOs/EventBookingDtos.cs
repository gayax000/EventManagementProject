using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.DTOs;

// 1. Create Event Request DTO
public class CreateEventRequestDto
{
    [Required, MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public string EventType { get; set; } = "Wedding";
    public string? CustomEventType { get; set; }

    [Required]
    public DateTime TargetDate { get; set; }

    [Range(1, 10000, ErrorMessage = "Guest count must be at least 1.")]
    public int GuestCount { get; set; }

    [Range(1000, 100000000, ErrorMessage = "Budget limit must be valid.")]
    public decimal BudgetLimit { get; set; }

    public Guid? VenueId { get; set; }
    public Guid? BanquetHallId { get; set; }
    public bool IsOutdoor { get; set; } = false;
    public string? AdditionalDetails { get; set; }
    public List<string>? InspirationImages { get; set; }
    public string? InspirationImageUrl { get; set; }
    public Guid? CustomerId { get; set; }
    public string? PreferredLocation { get; set; }

    public List<string>? SelectedServices { get; set; }
    public string? CustomServiceNotes { get; set; }
    public string? EventSession { get; set; } = "DayLunch";
    public string? CateringStyle { get; set; } = "InternationalBuffet";
    public List<string>? TableRefreshments { get; set; }
}

// 2. Event Response DTO
public class EventResponseDto
{
    public Guid EventId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string EventType { get; set; } = "Wedding";
    public DateTime TargetDate { get; set; }
    public int GuestCount { get; set; }
    public decimal BudgetLimit { get; set; }
    public bool IsOutdoor { get; set; } = false;
    public string? AdditionalDetails { get; set; }
    public string Status { get; set; } = string.Empty;
    public Guid? VenueId { get; set; }
    public string? VenueName { get; set; }
    public Guid? BanquetHallId { get; set; }
    public string? BanquetHallName { get; set; }
    public decimal? HallRentalPrice { get; set; }
    public decimal? PerPlatePrice { get; set; }
    public string? InspirationImageUrl { get; set; }
    public List<string> InspirationImages { get; set; } = new();
    public List<string>? SelectedServices { get; set; }
    public string? EventSession { get; set; }
    public string? CateringStyle { get; set; }
    public List<string>? TableRefreshments { get; set; }
    public string? PreferredLocation { get; set; }
    public string? RevisionNotes { get; set; }
    public decimal? EstimatedTotalCost { get; set; }
    public DateTime CreatedAt { get; set; }
}

// 2.0 Client Choice / Revision Request DTO
public class SubmitClientBudgetChoiceDto
{
    public string ClientAction { get; set; } = "accept"; // "accept" or "request_revision"
    public string? SelectedTier { get; set; }
    public string? RevisionNotes { get; set; }
}

// 2.1 Banquet Hall DTO
public class BanquetHallDto
{
    public Guid BanquetHallId { get; set; }
    public Guid VenueId { get; set; }
    public string VenueName { get; set; } = string.Empty;
    public string HallName { get; set; } = string.Empty;
    public int MaxCapacity { get; set; }
    public decimal HallRentalPrice { get; set; }
    public decimal PerPlatePrice { get; set; }
    public bool IsOutdoor { get; set; }
    public bool IsAvailable { get; set; } = true;
}

// 3. Digital Contract Sign DTO (Business-specific operation)
public class SignContractRequestDto
{
    [Required]
    public string DigitalSignatureUrl { get; set; } = string.Empty;

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