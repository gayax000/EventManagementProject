using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;
using Xunit;

namespace EventManagement.Tests;

public class ApiIntegrationTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public ApiIntegrationTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task RootHealthCheckEndpoint_ReturnsSuccessAndJson()
    {
        // Act
        var response = await _client.GetAsync("/");

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("EventManagement API", content);
    }

    [Fact]
    public async Task HealthEndpoint_ReturnsHealthyStatus()
    {
        // Act
        var response = await _client.GetAsync("/health");

        // Assert
        Assert.True(response.StatusCode == HttpStatusCode.OK || response.StatusCode == (HttpStatusCode)530);
    }

    [Fact]
    public async Task ProtectedPaymentsEndpoint_WithoutToken_ReturnsUnauthorized()
    {
        // Act
        var response = await _client.GetAsync("/api/payments");

        // Assert
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GetVenuesEndpoint_WithPagination_ReturnsOk()
    {
        // Act
        var response = await _client.GetAsync("/api/venues?pageNumber=1&pageSize=5");

        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("items", content, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("totalCount", content, StringComparison.OrdinalIgnoreCase);
    }
}
