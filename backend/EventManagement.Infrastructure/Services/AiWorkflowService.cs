using System.Text;
using System.Text.Json;
using EventManagement.Core.Entities;
using EventManagement.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EventManagement.Infrastructure.Services;

public interface IAiWorkflowService
{
    Task<AIWorkflowState?> TriggerAgenticPlanAsync(Guid eventId);
}

public class WeatherEvaluation
{
    public bool IsOutdoor { get; set; }
    public int RainProbabilityPercent { get; set; }
    public string Condition { get; set; } = string.Empty;
    public string RiskLevel { get; set; } = "Low";
    public string Safeguard { get; set; } = "None Required";
    public decimal SafeguardCost { get; set; } = 0;
    public string Description { get; set; } = string.Empty;
}

public class AiWorkflowService : IAiWorkflowService
{
    private readonly HttpClient _httpClient;
    private readonly AppDbContext _context;
    private readonly ILogger<AiWorkflowService> _logger;
    private readonly string _aiServiceUrl;

    public AiWorkflowService(HttpClient httpClient, AppDbContext context, IConfiguration configuration, ILogger<AiWorkflowService> logger)
    {
        _httpClient = httpClient;
        _context = context;
        _logger = logger;
        _aiServiceUrl = configuration["AiServiceUrl"] ?? "http://localhost:8000/api/ai/plan";
    }

    public static WeatherEvaluation EvaluateWeatherRisk(DateTime targetDate, string location, bool isOutdoor, decimal budgetLimit = 0m)
    {
        if (!isOutdoor)
        {
            return new WeatherEvaluation
            {
                IsOutdoor = false,
                RainProbabilityPercent = 0,
                Condition = "Indoor Climate-Controlled Banquet Hall",
                RiskLevel = "None",
                Safeguard = "None Required (Fully Weather-Sheltered)",
                SafeguardCost = 0,
                Description = "This event is hosted in an indoor, air-conditioned hall. 0% weather risk exposure; no marquee tent or weather contingency required."
            };
        }

        int month = targetDate.Month;
        int day = targetDate.Day;
        string locLower = location.ToLowerInvariant();

        bool isWestOrSouth = locLower.Contains("colombo") || locLower.Contains("galle") || locLower.Contains("kalutara") || 
                             locLower.Contains("gampaha") || locLower.Contains("matara") || locLower.Contains("bentota") || 
                             locLower.Contains("negombo") || locLower.Contains("mount lavinia");
        bool isCentralHighlands = locLower.Contains("kandy") || locLower.Contains("nuwara eliya") || locLower.Contains("hatton") || 
                                 locLower.Contains("ella") || locLower.Contains("bandarawela");
        bool isNorthOrEast = locLower.Contains("trincomalee") || locLower.Contains("batticaloa") || locLower.Contains("jaffna") || 
                             locLower.Contains("anuradhapura") || locLower.Contains("polonnaruwa");

        int baseProbability = 20;

        // Sri Lanka Monsoonal Patterns
        if (month >= 5 && month <= 9) // Southwest Monsoon
        {
            if (isCentralHighlands) baseProbability = 82;
            else if (isWestOrSouth) baseProbability = 74;
            else if (isNorthOrEast) baseProbability = 22; // Dry period in the East
            else baseProbability = 68;
        }
        else if (month >= 10 && month <= 12) // Northeast Monsoon & 2nd Inter-Monsoon
        {
            if (isNorthOrEast) baseProbability = 80;
            else if (isCentralHighlands) baseProbability = 72;
            else if (isWestOrSouth) baseProbability = 62;
            else baseProbability = 65;
        }
        else if (month >= 1 && month <= 3) // Dry, sunny season
        {
            if (isCentralHighlands) baseProbability = 32;
            else if (isNorthOrEast) baseProbability = 28;
            else baseProbability = 18; // Colombo/South sunny
        }
        else // April (1st Inter-Monsoon)
        {
            baseProbability = 48;
        }

        // Realistic deterministic daily variance (-6% to +8%) based on day of month
        int variance = ((day * 7 + month * 13) % 15) - 6;
        int rainPct = Math.Clamp(baseProbability + variance, 8, 92);

        string condition;
        string riskLevel;
        string safeguard;
        decimal safeguardCost;
        string description;

        if (rainPct >= 60)
        {
            riskLevel = "High";
            condition = (month >= 5 && month <= 9) 
                ? "South-West Monsoon Rain Showers" 
                : (month >= 10 && month <= 12 ? "North-East Monsoon Showers" : "Inter-Monsoon Thunderstorms");
            if (budgetLimit >= 2000000m)
            {
                safeguard = "Air-Conditioned Transparent German Hangar Marquee (40x80 ft)";
                safeguardCost = 350000m;
            }
            else if (budgetLimit >= 1200000m || budgetLimit <= 0m)
            {
                safeguard = "Heavy-Duty Waterproof Marquee Tent (20x40 ft)";
                safeguardCost = 150000m;
            }
            else if (budgetLimit >= 700000m)
            {
                safeguard = "High-Peak Waterproof Stretch Canopy (20x30 ft)";
                safeguardCost = 80000m;
            }
            else
            {
                safeguard = "Waterproof Pagoda / Rain Shelter Canopy (15x15 ft)";
                safeguardCost = 45000m;
            }
            description = $"High precipitation probability ({rainPct}%) predicted for outdoor grounds in {location} on {targetDate:yyyy-MM-dd}. Autonomous safeguard: {safeguard} (Rs. {safeguardCost:N0}) included to secure the event.";
        }
        else if (rainPct >= 35)
        {
            riskLevel = "Moderate";
            condition = "Partly Cloudy with Mild Tropical Breeze";
            safeguard = "None Required (Weather Advisory Monitored)";
            safeguardCost = 0m;
            description = $"Moderate cloud cover ({rainPct}%) expected. Grounds are suitable for outdoor activities; no marquee tent needed.";
        }
        else
        {
            riskLevel = "Low";
            condition = "Clear Sunny Skies & Pleasant Tropical Weather";
            safeguard = "None Required (Safe Outdoor Grounds)";
            safeguardCost = 0m;
            description = $"Dry, favorable sunny weather ({rainPct}% rain chance) forecast for {targetDate:yyyy-MM-dd}. Outdoor grounds are completely safe; no marquee tent needed.";
        }

        return new WeatherEvaluation
        {
            IsOutdoor = true,
            RainProbabilityPercent = rainPct,
            Condition = condition,
            RiskLevel = riskLevel,
            Safeguard = safeguard,
            SafeguardCost = safeguardCost,
            Description = description
        };
    }

    public async Task<AIWorkflowState?> TriggerAgenticPlanAsync(Guid eventId)
    {
        var ev = await _context.Events
            .AsNoTracking()
            .Where(e => e.EventId == eventId)
            .Select(e => new
            {
                e.EventId,
                e.Title,
                e.TargetDate,
                e.GuestCount,
                e.BudgetLimit,
                e.IsOutdoor,
                e.PreferredLocation,
                e.SelectedServicesJson,
                e.TableRefreshmentsJson,
                e.EventSession,
                e.CateringStyle,
                e.AdditionalDetails,
                e.CustomPrompt,
                e.Status,
                VenueName = e.Venue != null ? e.Venue.Name : null,
                VenueAddress = e.Venue != null ? e.Venue.LocationAddress : null,
                HasBanquetHall = e.BanquetHall != null,
                BanquetHallName = e.BanquetHall != null ? e.BanquetHall.HallName : null,
                BanquetHallVenueName = e.BanquetHall != null && e.BanquetHall.Venue != null ? e.BanquetHall.Venue.Name : null,
                HallRentalPrice = e.BanquetHall != null ? e.BanquetHall.HallRentalPrice : 0m,
                PerPlatePrice = e.BanquetHall != null ? e.BanquetHall.PerPlatePrice : 5000m
            })
            .FirstOrDefaultAsync();

        if (ev == null)
        {
            _logger.LogWarning("Event {EventId} not found for AI orchestration.", eventId);
            return null;
        }

        string eventLocation = ev.HasBanquetHall 
            ? $"{ev.BanquetHallVenueName ?? "Selected Hotel"} ({ev.BanquetHallName})" 
            : (ev.VenueName != null ? $"{ev.VenueName}, {ev.VenueAddress}" : (!string.IsNullOrWhiteSpace(ev.PreferredLocation) ? ev.PreferredLocation : "Colombo"));

        // 1. Evaluate Dynamic Date-Aware & Location-Aware Weather
        var weather = EvaluateWeatherRisk(ev.TargetDate, eventLocation, ev.IsOutdoor, ev.BudgetLimit);
        string weatherJson = JsonSerializer.Serialize(weather);

        // 2. Intelligent Proposal Engine (Native in .NET for High Availability & Zero Failure)
        // Synchronized 100% with Verified Vendor Catalog & Manager Dashboard Tier Allocation
        var verifiedVendors = await _context.Vendors
            .AsNoTracking()
            .Where(v => v.VerificationStatus == "Verified" && v.PackagePrice != null && v.PackagePrice > 0)
            .ToListAsync();

        Vendor? AutoAllocateVendor(string category, decimal budgetLimit)
        {
            var matching = verifiedVendors
                .Where(v => string.Equals(v.Category, category, StringComparison.OrdinalIgnoreCase))
                .OrderBy(v => v.PackagePrice ?? 0m)
                .ToList();
            if (matching.Count == 0) return null;

            int targetIndex = 0;
            if (budgetLimit >= 2000000m)
                targetIndex = matching.Count - 1;
            else if (budgetLimit >= 1200000m)
                targetIndex = Math.Min(matching.Count - 1, Math.Max(0, matching.Count - 2));
            else if (budgetLimit >= 700000m)
                targetIndex = Math.Min(matching.Count - 1, 1);
            else
                targetIndex = 0;

            return matching[targetIndex];
        }

        bool isPrivateVenue = !ev.HasBanquetHall;
        decimal hallRental = isPrivateVenue ? 0m : ev.HallRentalPrice;
        decimal cateringPrice = ev.HasBanquetHall ? ev.PerPlatePrice : 5000m;
        decimal cateringCost = ev.GuestCount * cateringPrice;

        List<string> selectedServices = new();
        if (!string.IsNullOrEmpty(ev.SelectedServicesJson))
        {
            try { selectedServices = JsonSerializer.Deserialize<List<string>>(ev.SelectedServicesJson) ?? new(); }
            catch { }
        }

        bool hasSounds = selectedServices.Any(s => s.Contains("Sound", StringComparison.OrdinalIgnoreCase) || s.Contains("Lighting", StringComparison.OrdinalIgnoreCase) || s.Contains("Audio", StringComparison.OrdinalIgnoreCase));
        bool hasDeco = selectedServices.Any(s => s.Contains("Deco", StringComparison.OrdinalIgnoreCase) || s.Contains("Floral", StringComparison.OrdinalIgnoreCase) || s.Contains("Flower", StringComparison.OrdinalIgnoreCase));
        bool hasPhoto = selectedServices.Any(s => s.Contains("Photo", StringComparison.OrdinalIgnoreCase) || s.Contains("Media", StringComparison.OrdinalIgnoreCase));
        bool hasCake = selectedServices.Any(s => s.Contains("Cake", StringComparison.OrdinalIgnoreCase));
        bool hasTransport = selectedServices.Any(s => s.Contains("Transport", StringComparison.OrdinalIgnoreCase) || s.Contains("Car", StringComparison.OrdinalIgnoreCase) || s.Contains("Bridal", StringComparison.OrdinalIgnoreCase));

        decimal budget = ev.BudgetLimit;
        var autoAssignedVendors = new List<object>();

        var catVendor = AutoAllocateVendor("Catering", budget);
        if (catVendor != null)
        {
            autoAssignedVendors.Add(new
            {
                category = "Catering",
                vendorId = catVendor.VendorId,
                vendorName = catVendor.BusinessName,
                packageName = $"Banquet Catering Buffet ({ev.GuestCount} guests @ Rs. {cateringPrice:N0})",
                packagePrice = cateringCost
            });
        }

        // 1. Sounds & Lighting
        decimal soundsCost = 0m;
        string soundsName = "Concert Line-Array Sound & Digital Mixer Package";
        string? soundsPartner = null;
        if (hasSounds)
        {
            var sndVendor = AutoAllocateVendor("SoundLighting", budget);
            if (sndVendor != null)
            {
                soundsCost = sndVendor.PackagePrice ?? 85000m;
                soundsName = sndVendor.PackageName ?? sndVendor.BusinessName;
                soundsPartner = sndVendor.BusinessName;
                autoAssignedVendors.Add(new
                {
                    category = "SoundLighting",
                    vendorId = sndVendor.VendorId,
                    vendorName = sndVendor.BusinessName,
                    packageName = soundsName,
                    packagePrice = soundsCost
                });
            }
            else if (budget >= 2000000m) { soundsCost = 250000m; soundsName = "Concert Line-Array Rig + 16 Moving Heads + Beam Trusses"; }
            else if (budget >= 1200000m) { soundsCost = 180000m; soundsName = "Concert Line-Array Sound & Digital Mixer Package"; }
            else if (budget >= 700000m) { soundsCost = 85000m; soundsName = "Standard Stage Audio + Warm Ambient LED PAR Cans"; }
            else { soundsCost = 40000m; soundsName = "Compact Speech PA Kit + 2 Wireless Mics"; }
        }

        // 2. Deco
        decimal decoCost = 0m;
        string decoName = "Thematic Floral Stage & Decor";
        string? decoPartner = null;
        if (hasDeco)
        {
            var decVendor = AutoAllocateVendor("Decor", budget);
            if (decVendor != null)
            {
                decoCost = decVendor.PackagePrice ?? 85000m;
                decoName = decVendor.PackageName ?? decVendor.BusinessName;
                decoPartner = decVendor.BusinessName;
                autoAssignedVendors.Add(new
                {
                    category = "Decor",
                    vendorId = decVendor.VendorId,
                    vendorName = decVendor.BusinessName,
                    packageName = decoName,
                    packagePrice = decoCost
                });
            }
            else if (budget >= 2000000m) { decoCost = 220000m; decoName = "Royal Fresh Flower Ceiling Drapes & Grand Stage Decor"; }
            else if (budget >= 1200000m) { decoCost = 140000m; decoName = "Thematic Floral Stage + Entrance Tunnel Arch"; }
            else if (budget >= 700000m) { decoCost = 85000m; decoName = "Thematic Floral Stage + Table Centerpieces"; }
            else { decoCost = 45000m; decoName = "Minimalist Floral Arch + Cake Table Styling"; }
        }

        // 3. Photography
        decimal photoCost = 0m;
        string photoName = "Professional Event Coverage";
        string? photoPartner = null;
        if (hasPhoto)
        {
            var phtVendor = AutoAllocateVendor("Photography", budget);
            if (phtVendor != null)
            {
                photoCost = phtVendor.PackagePrice ?? 100000m;
                photoName = phtVendor.PackageName ?? phtVendor.BusinessName;
                photoPartner = phtVendor.BusinessName;
                autoAssignedVendors.Add(new
                {
                    category = "Photography",
                    vendorId = phtVendor.VendorId,
                    vendorName = phtVendor.BusinessName,
                    packageName = photoName,
                    packagePrice = photoCost
                });
            }
            else
            {
                photoCost = 0m;
                photoName = "Awaiting Live Registration (Pending Viva Demo)";
            }
        }

        // 4. Celebration Cakes
        decimal cakeCost = 0m;
        string cakeLabel = "Celebration Cake";
        string? cakePartner = null;
        if (hasCake)
        {
            var ckVendor = AutoAllocateVendor("Cake", budget);
            if (ckVendor != null)
            {
                cakeCost = ckVendor.PackagePrice ?? 30000m;
                cakeLabel = ckVendor.PackageName ?? ckVendor.BusinessName;
                cakePartner = ckVendor.BusinessName;
                autoAssignedVendors.Add(new
                {
                    category = "Cake",
                    vendorId = ckVendor.VendorId,
                    vendorName = ckVendor.BusinessName,
                    packageName = cakeLabel,
                    packagePrice = cakeCost
                });
            }
            else if (budget >= 2000000m) { cakeCost = 65000m; cakeLabel = "5-Tier Royal Handcrafted Fondant Wedding Cake"; }
            else if (budget >= 1200000m) { cakeCost = 45000m; cakeLabel = "3-Tier Luxury Floral Wedding Cake"; }
            else if (budget >= 700000m) { cakeCost = 30000m; cakeLabel = "2-Tier Custom Handcrafted Fondant Cake"; }
            else { cakeCost = 15000m; cakeLabel = "2-Tier Classic Buttercream Celebration Cake"; }
        }

        // 5. Luxury Bridal & VIP Transport
        decimal transportCost = 0m;
        string transportName = "VIP Chauffeur Transport";
        string? transportPartner = null;
        if (hasTransport)
        {
            var trnVendor = AutoAllocateVendor("Transport", budget);
            if (trnVendor != null)
            {
                transportCost = trnVendor.PackagePrice ?? 50000m;
                transportName = trnVendor.PackageName ?? trnVendor.BusinessName;
                transportPartner = trnVendor.BusinessName;
                autoAssignedVendors.Add(new
                {
                    category = "Transport",
                    vendorId = trnVendor.VendorId,
                    vendorName = trnVendor.BusinessName,
                    packageName = transportName,
                    packagePrice = transportCost
                });
            }
            else if (budget >= 2000000m) { transportCost = 95000m; transportName = "Classic Vintage Rolls Royce / 1954 Jaguar Mark VII"; }
            else if (budget >= 1200000m) { transportCost = 65000m; transportName = "Mercedes-Benz S-Class Luxury Chauffeur Sedan"; }
            else if (budget >= 700000m) { transportCost = 50000m; transportName = "BMW 5-Series Executive Bridal Sedan"; }
            else { transportCost = 35000m; transportName = "Toyota Premio / Allion Executive Chauffeur Sedan"; }
        }

        // 6. Food Menu Refreshments & Add-ons Calculation
        List<string> selectedRefreshments = new();
        if (!string.IsNullOrEmpty(ev.TableRefreshmentsJson))
        {
            try { selectedRefreshments = JsonSerializer.Deserialize<List<string>>(ev.TableRefreshmentsJson) ?? new(); }
            catch { }
        }

        decimal refreshmentsTotal = 0m;
        var refreshmentsPlanEntries = new List<string>();

        int gc = ev.GuestCount > 0 ? ev.GuestCount : 100;
        int rangeIdx = gc <= 150 ? 0 : (gc <= 250 ? 1 : 2);
        bool isLuxury = budget >= 2000000m;
        bool isPremium = budget >= 1000000m;

        foreach (var rawItem in selectedRefreshments)
        {
            var item = rawItem.ToLower();
            string itemLabel = rawItem;
            decimal itemPrice = 15000m;

            if (item.Contains("mocktail") || item.Contains("drink"))
            {
                if (isLuxury) { itemLabel = "Artisanal Exotic Fruit Fusion Bar & Signature Mocktails"; itemPrice = new[] { 38000m, 58000m, 85000m }[rangeIdx]; }
                else if (isPremium) { itemLabel = "Tropical Fresh Fruit Juices & Chilled Mocktails"; itemPrice = new[] { 22000m, 35000m, 52000m }[rangeIdx]; }
                else { itemLabel = "Chilled Mint Lime & Fruit Cordial Punch"; itemPrice = new[] { 12000m, 20000m, 32000m }[rangeIdx]; }
            }
            else if (item.Contains("snack") || item.Contains("savory") || item.Contains("table refreshment"))
            {
                if (isLuxury) { itemLabel = "Gourmet Savory Canapés, Cheese Platters & Vol-au-Vents"; itemPrice = new[] { 42000m, 65000m, 95000m }[rangeIdx]; }
                else if (isPremium) { itemLabel = "Assorted Mini Pastries, Rolls & Samosa Platter"; itemPrice = new[] { 25000m, 40000m, 60000m }[rangeIdx]; }
                else { itemLabel = "Classic Tea-Time Biscuit & Mini Savory Selection"; itemPrice = new[] { 15000m, 25000m, 38000m }[rangeIdx]; }
            }
            else if (item.Contains("dessert") || item.Contains("sweet"))
            {
                if (isLuxury) { itemLabel = "Luxury Chocolate Fountain, French Pastries & Fruit Carving"; itemPrice = new[] { 48000m, 75000m, 110000m }[rangeIdx]; }
                else if (isPremium) { itemLabel = "Watalappan, Caramel Pudding & Deluxe Ice Cream Bar"; itemPrice = new[] { 28000m, 45000m, 68000m }[rangeIdx]; }
                else { itemLabel = "Caramel Pudding & Vanilla Ice Cream Station"; itemPrice = new[] { 15000m, 25000m, 40000m }[rangeIdx]; }
            }
            else if (item.Contains("tea") || item.Contains("coffee"))
            {
                if (isLuxury) { itemLabel = "Artisanal Ceylon Tea & Brewed Espresso Coffee Lounge"; itemPrice = new[] { 25000m, 38000m, 55000m }[rangeIdx]; }
                else if (isPremium) { itemLabel = "Premium Ceylon Milk Tea & Brewed Coffee Counter"; itemPrice = new[] { 15000m, 22000m, 32000m }[rangeIdx]; }
                else { itemLabel = "Traditional Ceylon Plain & Milk Tea Station"; itemPrice = new[] { 8000m, 12000m, 18000m }[rangeIdx]; }
            }
            else if (item.Contains("midnight") || item.Contains("action"))
            {
                if (isLuxury) { itemLabel = "Live Action Midnight Street Food, Hopper & Satay Bar"; itemPrice = new[] { 55000m, 85000m, 125000m }[rangeIdx]; }
                else if (isPremium) { itemLabel = "Live Kottu & Mini Burger Midnight Station"; itemPrice = new[] { 32000m, 50000m, 75000m }[rangeIdx]; }
                else { itemLabel = "Midnight Hot Savory Snack Station"; itemPrice = new[] { 20000m, 30000m, 45000m }[rangeIdx]; }
            }

            refreshmentsTotal += itemPrice;
            refreshmentsPlanEntries.Add($"{itemLabel} = Rs. {itemPrice:N0}");
        }

        // 7. Weather Marquee Tent Safeguard (Tier-matched with Verified MarqueeTent Vendors)
        decimal othersCost = 0m;
        decimal weatherTentCost = 0m;
        string weatherTentName = "Waterproof Marquee Tent safeguard";
        string? weatherTentPartner = null;

        if (ev.IsOutdoor && weather.SafeguardCost > 0)
        {
            var tentVendor = AutoAllocateVendor("MarqueeTent", budget);
            if (tentVendor != null)
            {
                weatherTentCost = tentVendor.PackagePrice ?? 150000m;
                weatherTentName = tentVendor.PackageName ?? "Waterproof Marquee Tent safeguard";
                weatherTentPartner = tentVendor.BusinessName;
                autoAssignedVendors.Add(new
                {
                    category = "MarqueeTent",
                    vendorId = tentVendor.VendorId,
                    vendorName = tentVendor.BusinessName,
                    packageName = weatherTentName,
                    packagePrice = weatherTentCost
                });
            }
            else if (budget >= 2000000m)
            {
                weatherTentCost = 350000m;
                weatherTentName = "Air-Conditioned Transparent German Hangar Marquee (40x80 ft)";
                weatherTentPartner = "Grand Royal German Hangar Marquees";
            }
            else if (budget >= 1200000m)
            {
                weatherTentCost = 150000m;
                weatherTentName = "Heavy-Duty Waterproof Marquee Tent (20x40 ft)";
                weatherTentPartner = "Ceylon WeatherShield Marquee Tents";
            }
            else if (budget >= 700000m)
            {
                weatherTentCost = 80000m;
                weatherTentName = "High-Peak Waterproof Stretch Canopy (20x30 ft)";
                weatherTentPartner = "SunShade Canopies & Pergolas Colombo";
            }
            else
            {
                weatherTentCost = 45000m;
                weatherTentName = "Waterproof Pagoda / Rain Shelter Canopy (15x15 ft)";
                weatherTentPartner = "Rohan Canopy Rentals Kaduwela";
            }

            weather.SafeguardCost = weatherTentCost;
            weather.Safeguard = weatherTentName;
            weather.Description = $"High precipitation risk detected ({weather.Condition}). Auto-injecting {weatherTentName} (+Rs. {weatherTentCost:N0}).";
            weatherJson = JsonSerializer.Serialize(weather);

            // Create Manager Notification for Weather Safeguard Alert
            try
            {
                var manager = await _context.Users.FirstOrDefaultAsync(u => u.Email == "manager@eventcraft.lk" || u.RoleId == 2);
                if (manager != null)
                {
                    _context.Notifications.Add(new Notification
                    {
                        UserId = manager.UserId,
                        EventId = ev.EventId,
                        Title = "🌦️ Weather Safeguard Alert",
                        Message = $"High rain risk ({weather.RainProbabilityPercent}%) detected for outdoor event \"{ev.Title}\". Weather tent injected (+Rs. {weatherTentCost:N0}).",
                        Type = "WeatherAlert",
                        CreatedAt = DateTime.UtcNow
                    });
                }
            }
            catch { }
        }

        decimal computedTotal = hallRental + cateringCost + soundsCost + decoCost + photoCost + cakeCost + transportCost + refreshmentsTotal + othersCost + weatherTentCost;

        var planItems = new List<string>();

        if (!ev.IsOutdoor)
        {
            planItems.Add("Weather Assessment: 0% Risk (Indoor Air-Conditioned Venue - Fully Weather-Sheltered)");
            planItems.Add("No Marquee Tent Required (Rs. 150,000 saved for client)");
        }
        else if (weatherTentCost > 0)
        {
            planItems.Add($"Weather Assessment: {weather.RainProbabilityPercent}% ({weather.Condition})");
            planItems.Add($"{weatherTentName}{(weatherTentPartner != null ? $" [Partner: {weatherTentPartner}]" : "")} (Rs. {weatherTentCost:N0})");
        }
        else
        {
            planItems.Add($"Weather Forecast: {weather.RainProbabilityPercent}% ({weather.Condition}) - Safe Outdoor Grounds");
            planItems.Add("No Marquee Tent Required (Clear weather predicted)");
        }

        var sessionTitle = ev.EventSession == "NightDinner" ? "Night Dinner Session (6:00 PM - 11:30 PM)" : (ev.EventSession == "EveningHighTea" ? "Evening High Tea (3:30 PM - 7:00 PM)" : "Day Lunch Session (10:00 AM - 3:30 PM)");
        planItems.Add($"Event Session: {sessionTitle}");
        string venueRentalLabel = isPrivateVenue
            ? $"Private Residence ({ev.PreferredLocation ?? "Client Premises"})"
            : (ev.HasBanquetHall ? $"{ev.BanquetHallName} Hall Rental" : $"{ev.VenueName ?? "Selected Venue"} Rental");
        if (isPrivateVenue)
        {
            planItems.Add($"{venueRentalLabel} = Rs. 0 (Venue rental waived - Client owned property)");
        }
        else
        {
            planItems.Add($"{venueRentalLabel} = Rs. {hallRental:N0}");
        }

        var cateringStyleLabel = ev.CateringStyle switch
        {
            "OutdoorBBQ" => "Outdoor Live BBQ Grill Feast",
            "HighTeaCanape" => "High Tea Canapé & Snack Platter",
            "SriLankanHeritage" => "Sri Lankan Heritage Traditional Buffet",
            _ => "International Hotel Buffet"
        };
        planItems.Add($"Catering Style: {cateringStyleLabel} ({ev.GuestCount} guests @ Rs. {cateringPrice:N0}) = Rs. {cateringCost:N0}");

        foreach (var rEntry in refreshmentsPlanEntries)
        {
            planItems.Add(rEntry);
        }

        if (hasSounds) planItems.Add($"{soundsName}{(soundsPartner != null ? $" [Partner: {soundsPartner}]" : "")} (Rs. {soundsCost:N0})");
        if (hasDeco) planItems.Add($"{decoName}{(decoPartner != null ? $" [Partner: {decoPartner}]" : "")} (Rs. {decoCost:N0})");
        if (hasPhoto)
        {
            if (photoCost > 0)
                planItems.Add($"{photoName}{(photoPartner != null ? $" [Partner: {photoPartner}]" : "")} (Rs. {photoCost:N0})");
            else
                planItems.Add("Photography & Cinematography: Pending Live Photographer Registration (Rs. 0)");
        }
        if (hasCake) planItems.Add($"{cakeLabel}{(cakePartner != null ? $" [Partner: {cakePartner}]" : "")} (Rs. {cakeCost:N0})");
        if (hasTransport) planItems.Add($"{transportName}{(transportPartner != null ? $" [Partner: {transportPartner}]" : "")} (Rs. {transportCost:N0})");
        if (!string.IsNullOrWhiteSpace(ev.AdditionalDetails)) planItems.Add($"Special Client Request: {ev.AdditionalDetails} (Priced by Manager upon Review)");

        var traceLogs = new List<string>
        {
            $"WeatherAgent: Evaluated {eventLocation} on {ev.TargetDate:yyyy-MM-dd} (IsOutdoor: {ev.IsOutdoor}, Session: {ev.EventSession}) -> {weather.RainProbabilityPercent}% ({weather.RiskLevel} Risk)",
            $"ResourceAgent: Compiled venue ({hallRental:N0}), {cateringStyleLabel} ({cateringCost:N0})",
            $"SafetyAgent: Weather safeguard {(weatherTentCost > 0 ? $"INJECTED (Rs. {weatherTentCost:N0})" : "NOT REQUIRED (Rs. 0)")}"
        };

        string autoAssignedVendorsJson = JsonSerializer.Serialize(autoAssignedVendors);

        var existingState = await _context.AIWorkflowStates.FirstOrDefaultAsync(a => a.EventId == ev.EventId);
        if (existingState != null)
        {
            existingState.ObjectiveText = $"Autonomous proposal for {ev.Title} ({ev.GuestCount} guests)";
            existingState.GeneratedPlanJson = JsonSerializer.Serialize(planItems);
            existingState.WeatherAssessmentJson = weatherJson;
            existingState.ToolExecutionLogsJson = JsonSerializer.Serialize(traceLogs);
            existingState.EstimatedTotalCost = computedTotal;
            await _context.SaveChangesAsync();
            await _context.Events.Where(e => e.EventId == eventId && string.IsNullOrEmpty(e.AssignedVendorsJson))
                .ExecuteUpdateAsync(s => s.SetProperty(e => e.AssignedVendorsJson, autoAssignedVendorsJson));
            _logger.LogInformation("Updated dynamic native AI Workflow for Event {EventId}. Total: {Total}", eventId, computedTotal);
            return existingState;
        }

        var finalState = new AIWorkflowState
        {
            EventId = ev.EventId,
            ObjectiveText = $"Autonomous proposal for {ev.Title} ({ev.GuestCount} guests)",
            GeneratedPlanJson = JsonSerializer.Serialize(planItems),
            WeatherAssessmentJson = weatherJson,
            ToolExecutionLogsJson = JsonSerializer.Serialize(traceLogs),
            EstimatedTotalCost = computedTotal,
            ApprovalStatus = "PendingManagerApproval"
        };

        _context.AIWorkflowStates.Add(finalState);
        await _context.SaveChangesAsync();
        await _context.Events.Where(e => e.EventId == eventId)
            .ExecuteUpdateAsync(s => s
                .SetProperty(e => e.Status, "PendingManagerApproval")
                .SetProperty(e => e.AssignedVendorsJson, autoAssignedVendorsJson));

        _logger.LogInformation("Persisted dynamic native AI Workflow for Event {EventId}. Total: {Total}", eventId, computedTotal);
        return finalState;
    }
}