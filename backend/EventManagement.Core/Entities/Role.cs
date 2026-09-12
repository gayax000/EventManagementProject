using System.ComponentModel.DataAnnotations;
namespace EventManagement.Core.Entities;
public class Role
{
    [Key]
    public int RoleId { get; set; }
    
    [Required, MaxLength(50)]
    public string RoleName { get; set; } = string.Empty; // Admin, Manager, Customer, Vendor
}