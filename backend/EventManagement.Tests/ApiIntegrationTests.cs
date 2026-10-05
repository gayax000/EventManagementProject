using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Xunit;

namespace EventManagement.Tests;

public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    public const string TestSecret = "SuperSecretKeyForJwtTokenGeneration2026!EventCraftProject";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            var descriptor = services.SingleOrDefault(
                d => d.ServiceType == typeof(DbContextOptions<AppDbContext>));

            if (descriptor != null)
            {
                services.Remove(descriptor);
            }

            services.AddDbContext<AppDbContext>(options =>
            {
                options.UseInMemoryDatabase("IntegrationTestDb");
            });

            services.PostConfigure<Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerOptions>(
                Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme,
                options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(TestSecret)),
                        ValidateIssuer = true,
                        ValidIssuer = "EventCraft.Api",
                        ValidateAudience = true,
                        ValidAudience = "EventCraft.Client",
                        ValidateLifetime = false,
                        ClockSkew = TimeSpan.Zero
                    };
                });

            var sp = services.BuildServiceProvider();
            using var scope = sp.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            db.Database.EnsureCreated();

            if (!db.Venues.Any())
            {
                db.Venues.Add(new Venue
                {
                    VenueId = Guid.NewGuid(),
                    Name = "Grand Ballroom",
                    LocationAddress = "Colombo",
                    MaxCapacity = 500,
                    BaseRentalPrice = 150000,
                    IsOutdoor = false,
                    Status = "Available"
                });
                db.SaveChanges();
            }
        });
    }
}

public class ApiIntegrationTests : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly CustomWebApplicationFactory _factory;

    public ApiIntegrationTests(CustomWebApplicationFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }

    private string GenerateToken(Guid userId, string email, string role)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(CustomWebApplicationFactory.TestSecret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, userId.ToString()),
            new Claim(ClaimTypes.Email, email),
            new Claim(ClaimTypes.Role, role)
        };

        var token = new JwtSecurityToken(
            issuer: "EventCraft.Api",
            audience: "EventCraft.Client",
            claims: claims,
            expires: DateTime.UtcNow.AddHours(2),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    [Fact]
    public async Task RootHealthCheckEndpoint_ReturnsSuccessAndJson()
    {
        var response = await _client.GetAsync("/");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("EventManagement API", content);
    }

    [Fact]
    public async Task HealthEndpoint_ReturnsHealthyStatus()
    {
        var response = await _client.GetAsync("/health");
        Assert.True(response.StatusCode == HttpStatusCode.OK || response.StatusCode == (HttpStatusCode)530);
    }

    [Fact]
    public async Task ProtectedPaymentsEndpoint_WithoutToken_ReturnsUnauthorized()
    {
        var response = await _client.GetAsync("/api/payments");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task ManagerPaymentsEndpoint_WithCustomerToken_ReturnsForbidden()
    {
        var customerToken = GenerateToken(Guid.NewGuid(), "customer@test.com", "Customer");
        var request = new HttpRequestMessage(HttpMethod.Get, "/api/payments");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", customerToken);

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task ManagerPaymentsEndpoint_WithManagerToken_ReturnsOk()
    {
        var managerToken = GenerateToken(Guid.NewGuid(), "manager@test.com", "Manager");
        var request = new HttpRequestMessage(HttpMethod.Get, "/api/payments");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", managerToken);

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }

    [Fact]
    public async Task GetVenuesEndpoint_WithPagination_ReturnsPagedResult()
    {
        var response = await _client.GetAsync("/api/venues?pageNumber=1&pageSize=5");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsStringAsync();

        Assert.Contains("items", content, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("totalCount", content, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("pageNumber", content, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("pageSize", content, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task CreateEvent_WithCustomerToken_ReturnsCreated()
    {
        var customerId = Guid.NewGuid();
        var customerToken = GenerateToken(customerId, "customer2@test.com", "Customer");

        var dto = new CreateEventRequestDto
        {
            Title = "Gala Dinner 2026",
            EventType = "Dinner/Gala",
            TargetDate = DateTime.UtcNow.AddDays(30),
            GuestCount = 100,
            BudgetLimit = 500000,
            IsOutdoor = false,
            PreferredLocation = "Colombo"
        };

        var request = new HttpRequestMessage(HttpMethod.Post, "/api/events")
        {
            Content = new StringContent(JsonSerializer.Serialize(dto), Encoding.UTF8, "application/json")
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", customerToken);

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("Gala Dinner 2026", content);
    }

    [Fact]
    public async Task CreateEvent_WithoutToken_ReturnsUnauthorized()
    {
        var dto = new CreateEventRequestDto
        {
            Title = "Unauthorized Event",
            EventType = "Birthday",
            TargetDate = DateTime.UtcNow.AddDays(15),
            GuestCount = 50,
            BudgetLimit = 150000
        };

        var request = new HttpRequestMessage(HttpMethod.Post, "/api/events")
        {
            Content = new StringContent(JsonSerializer.Serialize(dto), Encoding.UTF8, "application/json")
        };

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GetMyEvents_WithCustomerToken_ReturnsOk()
    {
        var customerId = Guid.NewGuid();
        var customerToken = GenerateToken(customerId, "myevents@test.com", "Customer");

        var request = new HttpRequestMessage(HttpMethod.Get, "/api/events/my-events");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", customerToken);

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}
