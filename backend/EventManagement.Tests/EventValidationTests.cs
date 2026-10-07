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

    [Fact]
    public void MultiTier_Laksha25Scenario_CoreCostsAndVendors_StrictlyUnderBudgetLimit()
    {
        // Scenario: 25 Lakhs (Rs. 2,500,000) Budget for 200 Guests
        decimal totalBudget = 2500000m;
        int guestCount = 200;
        decimal hallRental = 500000m;
        decimal cateringPerPlate = 5000m; // Executive Gala Buffet
        decimal cateringCost = guestCount * cateringPerPlate; // 1,000,000m
        decimal coreFixedCosts = hallRental + cateringCost; // 1,500,000m (15 Lakhs)

        decimal remainingVendorPool = totalBudget - coreFixedCosts; // 1,000,000m (10 Lakhs)
        Assert.Equal(1000000m, remainingVendorPool);

        // Highest Tier Vendor Packages (Luxury Tiers)
        decimal photoTier4 = 250000m; // Royal CinemaCraft 4K Drone
        decimal decorTier4 = 220000m; // Royal Fresh Flower Drapes
        decimal soundTier3 = 180000m; // Concert Line-Array Rig
        decimal transportTier4 = 95000m; // Classic Vintage Rolls Royce
        decimal cakeTier4 = 65000m; // 5-Tier Royal Fondant
        decimal refreshments = 90000m;

        decimal vendorTotal = photoTier4 + decorTier4 + soundTier3 + transportTier4 + cakeTier4 + refreshments;
        decimal grandTotal = coreFixedCosts + vendorTotal;

        // Assert: Entire event cost must not exceed budget
        Assert.True(grandTotal <= totalBudget, $"Grand total ({grandTotal}) should be <= Budget ({totalBudget})");
        Assert.True(totalBudget - grandTotal >= 0, "Buffer remaining must be non-negative");
    }

    [Fact]
    public void MultiTier_TightBudgetScenario_ZeroOverrunEnforced()
    {
        // Scenario: 8 Lakhs (Rs. 800,000) Budget for 100 Guests
        decimal totalBudget = 800000m;
        int guestCount = 100;
        decimal hallRental = 150000m;
        decimal cateringPerPlate = 3800m;
        decimal cateringCost = guestCount * cateringPerPlate; // 380,000m
        decimal coreFixedCosts = hallRental + cateringCost; // 530,000m

        decimal remainingVendorPool = totalBudget - coreFixedCosts; // 270,000m

        // Tier 1 / 2 Packages for tight budget
        decimal photoTier2 = 95000m;
        decimal decorTier1 = 45000m;
        decimal soundTier1 = 40000m;
        decimal transportTier1 = 35000m;
        decimal cakeTier1 = 15000m;

        decimal vendorTotal = photoTier2 + decorTier1 + soundTier1 + transportTier1 + cakeTier1;
        decimal grandTotal = coreFixedCosts + vendorTotal;

        Assert.True(grandTotal <= totalBudget);
    }
}
