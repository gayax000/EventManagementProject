using System.ComponentModel.DataAnnotations;

namespace EventManagement.Core.DTOs;

public class RegisterRequestDto
{
    [Required, MinLength(2, ErrorMessage = "Full name must be at least 2 characters long."), MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [Required, EmailAddress, MaxLength(150)]
    public string Email { get; set; } = string.Empty;

    [Required, MinLength(6, ErrorMessage = "Password must be at least 6 characters long.")]
    public string Password { get; set; } = string.Empty;

    [Required]
    [RegularExpression(@"^(?:\+94|0)[0-9]{9}$", ErrorMessage = "Please enter a valid phone number (e.g. 0771234567 or +94771234567).")]
    public string PhoneNumber { get; set; } = string.Empty;

    public string? Role { get; set; } = "Vendor";
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
    [RegularExpression("^(?i)(Verified|Rejected)$", ErrorMessage = "Status must be either 'Verified' or 'Rejected'.")]
    public string Status { get; set; } = "Verified";

    public string? AdminRemarks { get; set; }
}

public class RegisterVendorDto
{
    [Required, MinLength(2, ErrorMessage = "Business name must be at least 2 characters long."), MaxLength(150)]
    public string BusinessName { get; set; } = string.Empty;

    [Required]
    public string Category { get; set; } = "Catering";

    [Required]
    [RegularExpression(@"^(?:\+94|0)[0-9]{9}$", ErrorMessage = "Please enter a valid contact number (e.g. 0771234567 or +94771234567).")]
    public string ContactNumber { get; set; } = string.Empty;

    public string? Description { get; set; }
    public string? PackageName { get; set; }

    [Range(100, 100000000, ErrorMessage = "Package price must be at least 100 LKR.")]
    public decimal? PackagePrice { get; set; }
    public Guid? UserId { get; set; }
}