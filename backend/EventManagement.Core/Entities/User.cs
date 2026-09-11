using System.ComponentModel.DataAnnotations;
 
namespace EventManagement.Core.Entities;
 
public class User : BaseEntity
{
    [Key]
    public Guid UserId { get; set; } = Guid.NewGuid();
    [Required, MaxLength(100)]
    public string FullName { get; set; } = string.Empty;
    [Required, EmailAddress, MaxLength(150)]
    public string Email { get; set; } = string.Empty;
    [Required]
    public string PasswordHash { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string ProfileImageUrl { get; set; } = string.Empty;
    public string AccountStatus { get; set; } = "Active"; // Active, Suspended, Locked
    public int RoleId { get; set; }
    public Role? Role { get; set; }
}