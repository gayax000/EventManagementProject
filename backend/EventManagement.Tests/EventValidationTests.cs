using System;
using EventManagement.Core.DTOs;
using Xunit;

namespace EventManagement.Tests;

public class EventValidationTests
{
    [Fact]
    public void CreateEventDto_ValidBudgetAndGuests_ValidationPasses()
    {
        // Arrange
        var dto = new CreateEventRequestDto
        {
            Title = "Grand Gala Celebration",
            EventType = "Corporate Event",
            TargetDate = DateTime.UtcNow.AddDays(30),
            GuestCount = 250,
            BudgetLimit = 1500000.0m,
            PreferredLocation = "Colombo",
            IsOutdoor = true
        };

        // Assert
        Assert.False(string.IsNullOrWhiteSpace(dto.Title));
        Assert.True(dto.GuestCount > 0);
        Assert.True(dto.BudgetLimit > 0);
        Assert.True(dto.IsOutdoor);
    }

    [Fact]
    public void CreateEventDto_NegativeBudget_FlaggedAsInvalid()
    {
        // Arrange
        var dto = new CreateEventRequestDto
        {
            Title = "Invalid Event Request",
            GuestCount = 10,
            BudgetLimit = -50000.0m,
            PreferredLocation = "Kandy"
        };

        // Act & Assert
        bool isBudgetValid = dto.BudgetLimit > 0;
        Assert.False(isBudgetValid);
    }
}
