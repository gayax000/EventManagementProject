using System.Security.Claims;
using System.Text.Json;
using EventManagement.Api.Controllers;
using EventManagement.Core.DTOs;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using EventManagement.Infrastructure.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Moq;
using Xunit;

namespace EventManagement.Tests;

public class EventLoadingTests
{
    [Fact]
    public async Task ProposalAndEventList_PreserveHotelAndRegisteredVendorAssignments()
    {
        using var db = new AppDbContext(new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString()).Options);
        var customerId = Guid.NewGuid();
        db.Users.Add(new User { UserId = customerId, FullName = "Test customer", Email = "customer@example.test", PasswordHash = "test" });
        var vendorId = Guid.NewGuid().ToString();
        var ev = new Event
        {
            CustomerId = customerId,
            Title = "Hotel wedding",
            Status = "Confirmed",
            AssignedVendorsJson = $$"""
                [{"category":"Catering","vendorId":"hotel-in-house","vendorName":"Hotel kitchen","packagePrice":1375000},
                 {"category":"Photography","vendorId":"{{vendorId}}","vendorName":"Photographer","packagePrice":45000},
                 {"category":"Extra","vendorId":null,"vendorName":"Custom service"}]
                """
        };
        db.Events.Add(ev);
        await db.SaveChangesAsync();
        var controller = new EventsController(db, Mock.Of<IAiWorkflowService>(), NullLogger<EventsController>.Instance)
        {
            ControllerContext = new ControllerContext
            {
                HttpContext = new DefaultHttpContext
                {
                    User = new ClaimsPrincipal(new ClaimsIdentity(new[]
                    {
                        new Claim(ClaimTypes.NameIdentifier, customerId.ToString()),
                        new Claim(ClaimTypes.Role, "Customer")
                    }, "Test"))
                }
            }
        };

        var proposal = Assert.IsType<OkObjectResult>(await controller.GetEventProposal(ev.EventId));
        var json = JsonSerializer.SerializeToElement(proposal.Value);
        var assignments = json.GetProperty("assignedVendors");
        Assert.Equal(3, assignments.GetArrayLength());
        Assert.Equal("hotel-in-house", assignments[0].GetProperty("VendorId").GetString());
        Assert.Equal(vendorId, assignments[1].GetProperty("VendorId").GetString());
        Assert.Equal(1375000m, assignments[0].GetProperty("PackagePrice").GetDecimal());

        var list = Assert.IsType<OkObjectResult>(await controller.GetMyEvents(null, null, null, null, null));
        var events = Assert.IsType<List<EventResponseDto>>(list.Value);
        Assert.Equal("hotel-in-house", Assert.Single(events).AssignedVendors![0].VendorId);
    }
}
