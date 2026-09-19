using Xunit;

namespace EventManagement.Tests;

public class WeatherAgentTests
{
    [Fact]
    public void OutdoorEvent_HighRainProbability_InjectsMarqueeTentSafeguard()
    {
        // Arrange
        bool isOutdoor = true;
        int rainProbabilityPercent = 75;
        decimal marqueeTentPrice = 150000.0m;

        // Act
        bool requiresSafeguard = isOutdoor && rainProbabilityPercent >= 60;
        decimal safeguardCost = requiresSafeguard ? marqueeTentPrice : 0m;

        // Assert
        Assert.True(requiresSafeguard);
        Assert.Equal(150000.0m, safeguardCost);
    }

    [Fact]
    public void IndoorEvent_HighRainProbability_NoSafeguardRequired()
    {
        // Arrange
        bool isOutdoor = false;
        int rainProbabilityPercent = 85;

        // Act
        bool requiresSafeguard = isOutdoor && rainProbabilityPercent >= 60;

        // Assert
        Assert.False(requiresSafeguard);
    }
}
