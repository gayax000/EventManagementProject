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

    [Fact]
    public async Task CustomerA_Cannot_View_CustomerB_Payments()
    {
        var customerAId = Guid.NewGuid();
        var customerBId = Guid.NewGuid();

        // Seed an event and payment belonging to Customer B
        using (var scope = _factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var evB = new Event
            {
                EventId = Guid.NewGuid(),
                CustomerId = customerBId,
                Title = "Customer B Private Gala",
                EventType = "Dinner/Gala",
                TargetDate = DateTime.UtcNow.AddDays(10),
                GuestCount = 100,
                BudgetLimit = 500000,
                Status = "Confirmed"
            };
            var bookingB = new Booking
            {
                BookingId = Guid.NewGuid(),
                EventId = evB.EventId,
                Status = "Confirmed",
                BookingReferenceCode = "BK-" + Guid.NewGuid().ToString().Substring(0, 8),
                TotalAgreedAmount = 400000
            };
            var paymentB = new Payment
            {
                PaymentId = Guid.NewGuid(),
                BookingId = bookingB.BookingId,
                AmountPaid = 200000,
                Status = "Approved",
                PaymentMethod = "BankTransferSlip"
            };
            db.Events.Add(evB);
            db.Bookings.Add(bookingB);
            db.Payments.Add(paymentB);
            await db.SaveChangesAsync();
        }

        // Customer A queries my-payments attempting to inspect Customer B's data
        var tokenA = GenerateToken(customerAId, "customerA@test.com", "Customer");
        var request = new HttpRequestMessage(HttpMethod.Get, $"/api/payments/my-payments?customerId={customerBId}");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", tokenA);

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = await response.Content.ReadAsStringAsync();
        // Since caller is Customer A, the backend enforces customerAId from JWT and ignores customerBId query
        Assert.DoesNotContain("Customer B Private Gala", json);
    }

    [Fact]
    public async Task CustomerA_Cannot_Upload_Payment_To_CustomerB_Booking()
    {
        var customerAId = Guid.NewGuid();
        var customerBId = Guid.NewGuid();
        var eventBId = Guid.NewGuid();

        using (var scope = _factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var evB = new Event
            {
                EventId = eventBId,
                CustomerId = customerBId,
                Title = "Customer B Wedding",
                EventType = "Wedding",
                TargetDate = DateTime.UtcNow.AddDays(20),
                GuestCount = 200,
                BudgetLimit = 1500000,
                Status = "Confirmed"
            };
            var bookingB = new Booking
            {
                BookingId = Guid.NewGuid(),
                EventId = eventBId,
                Status = "Confirmed",
                BookingReferenceCode = "BK-" + Guid.NewGuid().ToString().Substring(0, 8),
                TotalAgreedAmount = 1000000
            };
            db.Events.Add(evB);
            db.Bookings.Add(bookingB);
            await db.SaveChangesAsync();
        }

        var tokenA = GenerateToken(customerAId, "customerA@test.com", "Customer");
        var uploadDto = new
        {
            eventId = eventBId,
            amountPaid = 50000.0,
            paymentMethod = "BankTransferSlip",
            slipImageUrl = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY44YAAAAASUVORK5CYII="
        };

        var request = new HttpRequestMessage(HttpMethod.Post, "/api/payments/upload-slip")
        {
            Content = new StringContent(JsonSerializer.Serialize(uploadDto), Encoding.UTF8, "application/json")
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", tokenA);

        var response = await _client.SendAsync(request);
        // Expect 403 Forbidden due to ownership check
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Customer_Cannot_Approve_AI_Workflow()
    {
        var customerId = Guid.NewGuid();
        var token = GenerateToken(customerId, "customer@test.com", "Customer");

        var request = new HttpRequestMessage(HttpMethod.Post, $"/api/aiworkflow/{Guid.NewGuid()}/approve")
        {
            Content = new StringContent(JsonSerializer.Serialize(new { Action = "Approve", ManagerRemarks = "Unauthorized approval" }), Encoding.UTF8, "application/json")
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task Anonymous_Cannot_Upload_Payment()
    {
        var uploadDto = new
        {
            eventId = Guid.NewGuid(),
            amountPaid = 50000.0,
            paymentMethod = "BankTransferSlip"
        };

        var request = new HttpRequestMessage(HttpMethod.Post, "/api/payments/upload-slip")
        {
            Content = new StringContent(JsonSerializer.Serialize(uploadDto), Encoding.UTF8, "application/json")
        };

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Manager_Can_Query_Another_Customers_Payments()
    {
        var managerId = Guid.NewGuid();
        var customerBId = Guid.NewGuid();
        var eventBId = Guid.NewGuid();

        using (var scope = _factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var evB = new Event
            {
                EventId = eventBId,
                CustomerId = customerBId,
                Title = "Customer B Corporate Event",
                EventType = "Corporate",
                TargetDate = DateTime.UtcNow.AddDays(15),
                GuestCount = 50,
                BudgetLimit = 300000,
                Status = "Confirmed"
            };
            var bookingB = new Booking
            {
                BookingId = Guid.NewGuid(),
                EventId = eventBId,
                Status = "Confirmed",
                BookingReferenceCode = "BK-" + Guid.NewGuid().ToString().Substring(0, 8),
                TotalAgreedAmount = 250000
            };
            var paymentB = new Payment
            {
                PaymentId = Guid.NewGuid(),
                BookingId = bookingB.BookingId,
                AmountPaid = 125000,
                Status = "Approved",
                PaymentMethod = "BankTransferSlip"
            };
            db.Events.Add(evB);
            db.Bookings.Add(bookingB);
            db.Payments.Add(paymentB);
            await db.SaveChangesAsync();
        }

        var managerToken = GenerateToken(managerId, "manager@eventcraft.lk", "Manager");
        var request = new HttpRequestMessage(HttpMethod.Get, $"/api/payments/my-payments?customerId={customerBId}");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", managerToken);

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var json = await response.Content.ReadAsStringAsync();
        Assert.Contains(eventBId.ToString(), json, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task VendorA_Cannot_View_VendorB_Assignments()
    {
        var vendorAUserId = Guid.NewGuid();
        var vendorBUserId = Guid.NewGuid();
        var vendorBId = Guid.NewGuid();

        using (var scope = _factory.Services.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var vendorB = new Vendor
            {
                VendorId = vendorBId,
                UserId = vendorBUserId,
                BusinessName = "Vendor B Exclusive Catering",
                Category = "Catering",
                ContactNumber = "0771234567",
                VerificationStatus = "Verified"
            };
            var ev = new Event
            {
                EventId = Guid.NewGuid(),
                CustomerId = Guid.NewGuid(),
                Title = "Vendor B Private Assignment Event",
                EventType = "Wedding",
                TargetDate = DateTime.UtcNow.AddDays(25),
                GuestCount = 120,
                BudgetLimit = 900000,
                Status = "ApprovedByManager",
                AssignedVendorsJson = JsonSerializer.Serialize(new[]
                {
                    new
                    {
                        vendorId = vendorBId.ToString(),
                        businessName = "Vendor B Exclusive Catering",
                        category = "Catering",
                        cost = 350000.0
                    }
                })
            };
            db.Vendors.Add(vendorB);
            db.Events.Add(ev);
            await db.SaveChangesAsync();
        }

        // Vendor A attempts to pass Vendor B's vendorId & userId via query params
        var vendorAToken = GenerateToken(vendorAUserId, "vendorA@eventcraft.lk", "Vendor");
        var request = new HttpRequestMessage(HttpMethod.Get, $"/api/venues/vendors/assigned-events?vendorId={vendorBId}&userId={vendorBUserId}");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", vendorAToken);

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);

        var content = await response.Content.ReadAsStringAsync();
        // Since caller is Vendor A, backend derives identity from JWT (Vendor A has 0 matching events)
        Assert.DoesNotContain("Vendor B Exclusive Catering", content);
    }
}
