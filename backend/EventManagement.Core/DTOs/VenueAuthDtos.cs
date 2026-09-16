using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.DTOs;

public class RegisterRequestDto
{
    [Required, MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [Required, EmailAddress, MaxLength(150)]
    public string Email { get; set; } = string.Empty;

    [Required, MinLength(6)]
    public string Password { get; set; } = string.Empty;

    public string PhoneNumber { get; set; } = string.Empty;
}

public class LoginRequestDto
{
    [Required, EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string Password { get; set; } = string.Empty;
}

public class AuthResponseDto
{
    public Guid UserId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string Token { get; set; } = string.Empty;
}

public class CreateVenueDto
{
    [Required, MaxLength(150)]
    public string Name { get; set; } = string.Empty;

    [Required]
    public string LocationAddress { get; set; } = string.Empty;

    [Range(10, 50000)]
    public int MaxCapacity { get; set; }

    [Range(1000, 100000000)]
    public decimal BaseRentalPrice { get; set; }

    public bool IsOutdoor { get; set; }
}

public class VerifyVendorDto
{
    [Required]
    public string Status { get; set; } = "Verified";

    public string? AdminRemarks { get; set; }
}

public class RegisterVendorDto
{
    [Required, MaxLength(150)]
    public string BusinessName { get; set; } = string.Empty;

    [Required]
    public string Category { get; set; } = "Catering";

    [Required]
    public string ContactNumber { get; set; } = string.Empty;

    public string? Description { get; set; }
}