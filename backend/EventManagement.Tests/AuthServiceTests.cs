using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Services;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace EventManagement.Tests;

public class AuthServiceTests
{
    [Fact]
    public void GenerateToken_ValidUser_ReturnsSignedJwtToken()
    {
        // Arrange
        var inMemorySettings = new Dictionary<string, string?>
        {
            { "JwtSettings:SecretKey", "EventCraftAI_Super_Secret_JWT_Signing_Key_2026_SE3090!" },
            { "JwtSettings:Issuer", "EventCraft.Api" },
            { "JwtSettings:Audience", "EventCraft.Client" },
            { "JwtSettings:ExpiryInDays", "7" }
        };

        IConfiguration config = new ConfigurationBuilder()
            .AddInMemoryCollection(inMemorySettings)
            .Build();

        var jwtGenerator = new JwtTokenGenerator(config);
        var testUser = new User
        {
            UserId = Guid.NewGuid(),
            FullName = "Kasun Bandara",
            Email = "kasun@eventcraft.lk"
        };

        // Act
        var token = jwtGenerator.GenerateToken(testUser, "Manager");

        // Assert
        Assert.NotNull(token);
        Assert.NotEmpty(token);
        Assert.Contains(".", token); // JWT 3-part format: header.payload.signature
    }

    [Fact]
    public void BCrypt_HashPassword_And_Verify_ReturnsTrue()
    {
        // Arrange
        string rawPassword = "TestPassword123!";

        // Act
        string hashedPassword = BCrypt.Net.BCrypt.HashPassword(rawPassword);
        bool isValid = BCrypt.Net.BCrypt.Verify(rawPassword, hashedPassword);

        // Assert
        Assert.NotEqual(rawPassword, hashedPassword);
        Assert.StartsWith("$2", hashedPassword);
        Assert.True(isValid);
    }
}
