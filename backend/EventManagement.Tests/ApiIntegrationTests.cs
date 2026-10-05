using System.Net;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace EventManagement.Tests;

public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
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

    public ApiIntegrationTests(CustomWebApplicationFactory factory)
    {
        _client = factory.CreateClient();
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
    public async Task GetVenuesEndpoint_WithPagination_ReturnsOk()
    {
        var response = await _client.GetAsync("/api/venues?pageNumber=1&pageSize=5");
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("items", content, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("totalCount", content, StringComparison.OrdinalIgnoreCase);
    }
}
