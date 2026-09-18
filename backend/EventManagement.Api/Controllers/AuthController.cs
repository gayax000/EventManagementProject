using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Core.Interfaces;
using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EventManagement.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IJwtTokenGenerator _jwtTokenGenerator;

    public AuthController(AppDbContext context, IJwtTokenGenerator jwtTokenGenerator)
    {
        _context = context;
        _jwtTokenGenerator = jwtTokenGenerator;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register([FromBody] RegisterRequestDto dto)
    {
        if (await _context.Users.AnyAsync(u => u.Email == dto.Email))
            return BadRequest(new { message = "Email is already registered." });

        var targetRoleName = !string.IsNullOrEmpty(dto.Role) ? dto.Role : "Vendor";
        var role = await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == targetRoleName)
                   ?? await _context.Roles.FirstOrDefaultAsync(r => r.RoleName == "Customer")
                   ?? new Role { RoleName = targetRoleName };

        // Hash password securely via BCrypt
        var hashedPassword = BCrypt.Net.BCrypt.HashPassword(dto.Password);

        var user = new User
        {
            FullName = dto.FullName,
            Email = dto.Email,
            PasswordHash = hashedPassword,
            PhoneNumber = dto.PhoneNumber,
            RoleId = role.RoleId
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var token = _jwtTokenGenerator.GenerateToken(user, targetRoleName);

        return CreatedAtAction(nameof(Register), new AuthResponseDto
        {
            UserId = user.UserId,
            FullName = user.FullName,
            Email = user.Email,
            Role = targetRoleName,
            Token = token
        });
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login([FromBody] LoginRequestDto dto)
    {
        var user = await _context.Users.Include(u => u.Role).FirstOrDefaultAsync(u => u.Email == dto.Email);
        if (user == null)
            return Unauthorized(new { message = "Invalid email or password." });

        // Verify password hash via BCrypt (with graceful fallback for legacy seed accounts)
        bool isValidPassword = false;
        if (!string.IsNullOrEmpty(user.PasswordHash))
        {
            if (user.PasswordHash.StartsWith("$2a$") || user.PasswordHash.StartsWith("$2b$") || user.PasswordHash.StartsWith("$2y$"))
            {
                isValidPassword = BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash);
            }
            else
            {
                // Fallback for unhashed legacy seed passwords
                isValidPassword = (user.PasswordHash == dto.Password);
            }
        }

        if (!isValidPassword)
            return Unauthorized(new { message = "Invalid email or password." });

        var roleName = user.Role?.RoleName ?? "Customer";
        var token = _jwtTokenGenerator.GenerateToken(user, roleName);

        return Ok(new AuthResponseDto
        {
            UserId = user.UserId,
            FullName = user.FullName,
            Email = user.Email,
            Role = roleName,
            Token = token
        });
    }
}