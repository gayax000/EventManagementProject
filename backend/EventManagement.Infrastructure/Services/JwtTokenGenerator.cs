using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using EventManagement.Core.Entities;
using EventManagement.Core.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace EventManagement.Infrastructure.Services;

public class JwtTokenGenerator : IJwtTokenGenerator
{
    private readonly IConfiguration _configuration;

    public JwtTokenGenerator(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public string GenerateToken(User user, string roleName)
    {
        var secretKey = _configuration["JwtSettings:SecretKey"] 
            ?? "EventCraftAI_Super_Secret_JWT_Signing_Key_2026_SE3090!";
        var issuer = _configuration["JwtSettings:Issuer"] ?? "EventCraft.Api";
        var audience = _configuration["JwtSettings:Audience"] ?? "EventCraft.Client";
        var expiryDaysStr = _configuration["JwtSettings:ExpiryInDays"] ?? "7";
        _ = double.TryParse(expiryDaysStr, out double expiryDays);
        if (expiryDays <= 0) expiryDays = 7;

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
            new Claim(ClaimTypes.Email, user.Email ?? string.Empty),
            new Claim(ClaimTypes.Name, user.FullName ?? string.Empty),
            new Claim(ClaimTypes.Role, roleName ?? "Customer")
        };

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddDays(expiryDays),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
