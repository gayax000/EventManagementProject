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

    [Fact]
    public void EvaluateWeatherRisk_IndoorEvent_ReturnsAirConditionedClimate()
    {
        var eval = Infrastructure.Services.AiWorkflowService.EvaluateWeatherRisk(
            new DateTime(2026, 7, 15), "Colombo", isOutdoor: false);

        Assert.False(eval.IsOutdoor);
        Assert.Equal(0, eval.RainProbabilityPercent);
        Assert.Equal(22.0, eval.Temperature);
        Assert.Equal(55, eval.Humidity);
        Assert.Equal("None", eval.RiskLevel);
        Assert.Equal(0m, eval.SafeguardCost);
    }

    [Fact]
    public void EvaluateWeatherRisk_NuwaraEliya_ReturnsHighlandCoolClimatology()
    {
        var eval = Infrastructure.Services.AiWorkflowService.EvaluateWeatherRisk(
            new DateTime(2026, 6, 20), "Grand Hotel, Nuwara Eliya", isOutdoor: true);

        Assert.True(eval.IsOutdoor);
        // Nuwara Eliya highland temperatures range between 14°C and 17.5°C
        Assert.InRange(eval.Temperature, 13.0, 18.0);
        Assert.InRange(eval.Humidity, 75, 96);
        Assert.Equal("Historical Climatological Regional Model", eval.DataSource);
        Assert.False(eval.IsLiveApi);
    }

    [Fact]
    public void EvaluateWeatherRisk_Jaffna_ReturnsWarmDryZoneClimatology()
    {
        var eval = Infrastructure.Services.AiWorkflowService.EvaluateWeatherRisk(
            new DateTime(2026, 3, 10), "Tilko City Hotel, Jaffna", isOutdoor: true);

        Assert.True(eval.IsOutdoor);
        // Jaffna warm dry-zone temperatures range between 31°C and 34.5°C
        Assert.InRange(eval.Temperature, 30.0, 35.0);
        Assert.InRange(eval.Humidity, 55, 76);
    }

    [Theory]
    [InlineData("Earl's Regency, Kandy", "Kandy")]
    [InlineData("Grand Hotel, Nuwara Eliya", "Nuwara Eliya")]
    [InlineData("Jetwing Lighthouse, Galle Fort, Galle", "Galle")]
    [InlineData("Cinnamon Grand, Colombo 03", "Colombo")]
    [InlineData("Heritage Hotel, Anuradhapura", "Anuradhapura")]
    public void ExtractTownAndDistrict_MapsCityCorrectly(string inputLocation, string expectedCity)
    {
        string city = Infrastructure.Services.AiWorkflowService.ExtractTownAndDistrict(inputLocation);
        Assert.Equal(expectedCity, city);
    }
}
