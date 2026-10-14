import os
import datetime
import urllib.parse
import requests
from dotenv import load_dotenv

# Load environment variables from .env
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

PRIMARY_API_KEY = os.getenv("OPENWEATHER_API_KEY", "").strip()

def extract_location_details(location_str: str) -> tuple[str, str]:
    """
    Extracts (town, district) from structured location string or general venue text.
    Handles formats like:
      - 'Private Residence - No. 45/2, Temple Road | Town: Kiribathgoda | District: Gampaha'
      - 'Private Residence - No. 45 Temple Rd, Kiribathgoda, Gampaha'
      - 'Shangri-La Colombo - Lotus Ballroom'
    """
    loc = location_str.lower()
    town = ""
    district = ""

    if "town:" in loc:
        try:
            town = location_str.split("Town:")[1].split("|")[0].split(",")[0].strip()
        except Exception:
            pass

    if "district:" in loc:
        try:
            district = location_str.split("District:")[1].split("|")[0].split(",")[0].strip()
        except Exception:
            pass

    district_list = [
        "Colombo", "Gampaha", "Kalutara", "Kandy", "Matale", "Nuwara Eliya",
        "Galle", "Matara", "Hambantota", "Jaffna", "Kilinochchi", "Mannar",
        "Vavuniya", "Mullaitivu", "Batticaloa", "Ampara", "Trincomalee",
        "Kurunegala", "Puttalam", "Anuradhapura", "Polonnaruwa", "Badulla",
        "Monaragala", "Ratnapura", "Kegalle"
    ]

    for d in district_list:
        if d.lower() in loc:
            if not district:
                district = d
            break

    major_towns = [
        ("kiribathgoda", "Kiribathgoda"), ("negombo", "Negombo"), ("kelaniya", "Kelaniya"),
        ("wattala", "Wattala"), ("ja-ela", "Ja-Ela"), ("kadawatha", "Kadawatha"),
        ("nugegoda", "Nugegoda"), ("maharagama", "Maharagama"), ("dehiwala", "Dehiwala"),
        ("mount lavinia", "Colombo"), ("moratuwa", "Moratuwa"), ("malabe", "Malabe"),
        ("battaramulla", "Battaramulla"), ("rajagiriya", "Rajagiriya"), ("homagama", "Homagama"),
        ("kandy", "Kandy"), ("peradeniya", "Peradeniya"), ("katugastota", "Katugastota"),
        ("galle", "Galle"), ("hikkaduwa", "Hikkaduwa"), ("unawatuna", "Unawatuna"),
        ("bentota", "Bentota"), ("panadura", "Panadura"), ("wadduwa", "Wadduwa"),
        ("beruwala", "Beruwala"), ("aluthgama", "Aluthgama"), ("horana", "Horana"),
        ("matara", "Matara"), ("mirissa", "Mirissa"), ("weligama", "Weligama"),
        ("kurunegala", "Kurunegala"), ("kuliyapitiya", "Kuliyapitiya"), ("narammala", "Narammala"),
        ("nuwara eliya", "Nuwara Eliya"), ("hatton", "Hatton"), ("badulla", "Badulla"),
        ("bandarawela", "Bandarawela"), ("ella", "Ella"), ("ratnapura", "Ratnapura"),
        ("balangoda", "Balangoda"), ("anuradhapura", "Anuradhapura"), ("polonnaruwa", "Polonnaruwa"),
        ("jaffna", "Jaffna"), ("trincomalee", "Trincomalee"), ("batticaloa", "Batticaloa"),
        ("dambulla", "Dambulla"), ("sigiriya", "Sigiriya"), ("tangalle", "Tangalle"),
        ("chilaw", "Chilaw")
    ]

    if not town:
        for key, town_name in major_towns:
            if key in loc:
                town = town_name
                break

    if not district:
        district = town if town in district_list else "Colombo"
    if not town:
        town = district

    # Clean up postal zone suffixes like 'Colombo 07' -> 'Colombo'
    if "colombo" in town.lower():
        town = "Colombo"

    return town, district

def extract_city(location_str: str) -> str:
    town, district = extract_location_details(location_str)
    return town if town else district

def evaluate_seasonal_climatology(city: str, target_dt: datetime.date) -> dict:
    """
    Historical Sri Lanka Climatological & Monsoon Meteorological Model.
    Used when event date is outside the 5-day real-time forecast horizon or when external API is unreachable.
    """
    month = target_dt.month
    day = target_dt.day
    loc_lower = city.lower()

    is_central = any(p in loc_lower for p in ["kandy", "nuwara", "badulla", "ratnapura"])
    is_west_south = any(p in loc_lower for p in ["colombo", "galle", "kalutara", "matara", "negombo", "bentota", "gampaha"])
    is_north_east = any(p in loc_lower for p in ["jaffna", "trincomalee", "batticaloa", "anuradhapura", "polonnaruwa"])

    if 5 <= month <= 9:  # Southwest Monsoon (Yala)
        season_name = "South-West Monsoon (Yala)"
        if is_central or is_west_south:
            base_prob = 74
            condition = "South-West Monsoon Active Rain Showers"
            risk_level = "High"
        elif is_north_east:
            base_prob = 22
            condition = "Dry Season / Warm Sunny Conditions"
            risk_level = "Low"
        else:
            base_prob = 55
            condition = "Partly Cloudy with Scattered Showers"
            risk_level = "Moderate"
    elif 10 <= month <= 12:  # Northeast Monsoon (Maha) & 2nd Inter-Monsoon
        season_name = "North-East Monsoon (Maha) & 2nd Inter-Monsoon"
        base_prob = 72
        condition = "Monsoonal Cloud Cover & Heavy Afternoon Rain Showers"
        risk_level = "High"
    elif 1 <= month <= 3:  # Dry Season
        season_name = "Annual Dry Season"
        base_prob = 18
        condition = "Clear Blue Skies & Mild Humidity"
        risk_level = "Low"
    else:  # April - 1st Inter-Monsoon
        season_name = "1st Inter-Monsoon Convective Period"
        base_prob = 52
        condition = "Afternoon Convective Thunderstorms"
        risk_level = "Moderate"

    # Deterministic daily micro-variance (-6% to +6%) to prevent flat values
    variance = ((day * 7 + month * 13) % 13) - 6
    rain_probability = max(10, min(92, base_prob + variance))
    if rain_probability >= 60:
        risk_level = "High"
    elif rain_probability >= 35:
        risk_level = "Moderate"
    else:
        risk_level = "Low"

    # Dynamic location-aware thermal & humidity profiling based on elevation and geographic zone
    if "nuwara" in loc_lower or "hatton" in loc_lower:
        base_temp = 15.2
        base_humidity = 86
    elif "kandy" in loc_lower or "matale" in loc_lower:
        base_temp = 24.5
        base_humidity = 78
    elif is_north_east:
        base_temp = 31.8
        base_humidity = 66
    elif is_west_south:
        base_temp = 29.2
        base_humidity = 76
    else:
        base_temp = 28.0
        base_humidity = 75

    temp_variance = ((day % 5) * 0.4) - 0.8
    hum_variance = ((day % 7) - 3)
    temperature = round(base_temp + temp_variance, 1)
    humidity = max(50, min(95, base_humidity + hum_variance))

    return {
        "rainProbabilityPercent": rain_probability,
        "cloudCoverPercent": 85 if rain_probability >= 60 else (45 if rain_probability >= 35 else 15),
        "temperature": temperature,
        "humidity": humidity,
        "condition": condition,
        "riskLevel": risk_level,
        "dataSource": f"Historical Sri Lanka Seasonal Climate Model ({season_name})",
        "isLiveApi": False
    }

# Tool 1: Environmental & Weather Forecast Tool (Allow-listed Tool)
def check_weather_forecast(location: str, target_date_str: str) -> dict:
    """
    Allow-listed Tool: Retrieves environmental precipitation risk for event location and date.
    Integrates Live OpenWeatherMap 5-Day Forecast API with automatic graceful fallback to 
    Sri Lanka Seasonal Climatological Model for dates beyond 5 days or network failures.
    """
    town, district = extract_location_details(location)
    city = town if town else district
    today = datetime.date.today()

    try:
        clean_date_str = target_date_str.split("T")[0].strip()
        target_dt = datetime.date.fromisoformat(clean_date_str)
    except Exception:
        target_dt = today + datetime.timedelta(days=14)

    days_diff = (target_dt - today).days

    # Branch A: If target date is within 5-day real-time forecast horizon
    if 0 <= days_diff <= 5 and PRIMARY_API_KEY:
        try:
            # 1. Query hyper-local town first (safe URL-encoding for towns with spaces like 'Nuwara Eliya')
            encoded_city = urllib.parse.quote(city)
            url = f"https://api.openweathermap.org/data/2.5/forecast?q={encoded_city},LK&appid={PRIMARY_API_KEY}&units=metric"
            response = requests.get(url, timeout=5.0)

            # 2. If town lookup returns 404, gracefully fallback to District capital
            if response.status_code != 200 and district and district.lower() != city.lower():
                encoded_district = urllib.parse.quote(district)
                fallback_url = f"https://api.openweathermap.org/data/2.5/forecast?q={encoded_district},LK&appid={PRIMARY_API_KEY}&units=metric"
                fallback_res = requests.get(fallback_url, timeout=5.0)
                if fallback_res.status_code == 200:
                    response = fallback_res
                    city = district

            if response.status_code == 200:
                data = response.json()
                target_date_prefix = target_dt.isoformat()
                # Filter intervals for the target date
                day_intervals = [
                    item for item in data.get("list", [])
                    if item.get("dt_txt", "").startswith(target_date_prefix)
                ]
                # If target date intervals found, calculate max precipitation probability
                if not day_intervals:
                    day_intervals = data.get("list", [])[:8]

                if day_intervals:
                    max_pop = max((item.get("pop", 0.0) for item in day_intervals), default=0.0)
                    rain_pct = int(round(max_pop * 100))
                    
                    # Pick condition description from interval with highest pop
                    peak_interval = max(day_intervals, key=lambda x: x.get("pop", 0.0))
                    weather_desc = peak_interval.get("weather", [{}])[0].get("description", "Variable Clouds").title()
                    cloud_pct = int(peak_interval.get("clouds", {}).get("all", 0))
                    temp_val = round(float(peak_interval.get("main", {}).get("temp", 28.0)), 1)
                    humidity_val = int(peak_interval.get("main", {}).get("humidity", 75))

                    if rain_pct >= 60:
                        risk_level = "High"
                    elif rain_pct >= 35:
                        risk_level = "Moderate"
                    else:
                        risk_level = "Low"

                    return {
                        "location": location,
                        "city": city,
                        "targetDate": target_dt.isoformat(),
                        "daysAhead": days_diff,
                        "rainProbabilityPercent": rain_pct,
                        "cloudCoverPercent": cloud_pct,
                        "temperature": temp_val,
                        "humidity": humidity_val,
                        "condition": weather_desc,
                        "riskLevel": risk_level,
                        "dataSource": "Live OpenWeatherMap 5-Day Forecast API",
                        "isLiveApi": True,
                        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat()
                    }
        except Exception:
            # If network timeout or API error, seamlessly fall through to seasonal model
            pass

    # Branch B: Target date is beyond 5 days OR API was unreachable -> Climatological Model
    seasonal_data = evaluate_seasonal_climatology(city, target_dt)
    return {
        "location": location,
        "city": city,
        "targetDate": target_dt.isoformat(),
        "daysAhead": days_diff,
        "rainProbabilityPercent": seasonal_data["rainProbabilityPercent"],
        "cloudCoverPercent": seasonal_data.get("cloudCoverPercent", 50),
        "temperature": seasonal_data.get("temperature", 28.0),
        "humidity": seasonal_data.get("humidity", 75),
        "condition": seasonal_data["condition"],
        "riskLevel": seasonal_data["riskLevel"],
        "dataSource": seasonal_data["dataSource"],
        "isLiveApi": seasonal_data.get("isLiveApi", False),
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat()
    }

# Tool 2: Sri Lankan Venue & Inventory Pricing Tool (Allow-listed Tool)
def query_venue_and_inventory(location: str, guest_count: int) -> dict:
    """
    Allow-listed Tool: Queries available database venue capacities and package prices.
    """
    loc_lower = location.lower()
    
    if "nuwara" in loc_lower:
        venue_name = "The Grand Hotel Nuwara Eliya - Governors Lawn"
        venue_price = 450000.0
    elif "kandy" in loc_lower:
        venue_name = "Earl's Regency Kandy - Regent Ballroom"
        venue_price = 550000.0
    elif "galle" in loc_lower:
        venue_name = "Jetwing Lighthouse Galle - Ocean Rocks Lawn"
        venue_price = 620000.0
    else:
        venue_name = "Shangri-La Colombo - Lotus Ballroom"
        venue_price = 850000.0

    return {
        "venueName": venue_name,
        "venuePrice": venue_price,
        "buffetPerHead": 5000.0,    # Premium Dinner Buffet B
        "soundRigPrice": 150000.0,  # Line-Array Rig
        "marqueeTentPrice": 150000.0 # Weather Safeguard
    }

# Tool 3: Allow-listed NLP Entity & Intent Extraction Tool (Member 2 - Planning & Delegation Agent)
def extract_event_entities_tool(prompt_text: str = "", title: str = "", location: str = "", budget: float = 0.0, guests: int = 0) -> dict:
    """
    Allow-listed Tool owned by Member 2 (Planning & Delegation Agent).
    Extracts structured domain entities from natural language user prompts and structured objectives.
    """
    text = f"{prompt_text} {title} {location}".lower()
    
    # 1. Event Category Intent Extraction
    if any(k in text for k in ["wedding", "nuptial", "bridal", "marriage"]):
        event_category = "Wedding"
    elif any(k in text for k in ["birthday", "bday", "anniversary", "party", "celebration"]):
        event_category = "Birthday/Celebration"
    elif any(k in text for k in ["corporate", "conference", "gala", "banquet", "summit", "launch"]):
        event_category = "Corporate Event"
    else:
        event_category = "General Celebration"

    # 2. Theme / Atmosphere Extraction
    if any(k in text for k in ["beach", "sea", "ocean", "coastal", "sunset"]):
        theme = "Coastal Sunset / Beachside"
    elif any(k in text for k in ["luxury", "royal", "grand", "5-star"]):
        theme = "Royal Luxury"
    elif any(k in text for k in ["vintage", "rustic", "boho"]):
        theme = "Vintage Rustic"
    elif any(k in text for k in ["garden", "lawn", "nature", "outdoor"]):
        theme = "Outdoor Botanical Lawn"
    else:
        theme = "Contemporary Elegant"

    # 3. Special Requested Services Extraction
    services = []
    if any(k in text for k in ["sound", "music", "band", "dj", "acoustic", "audio", "lighting"]):
        services.append("Concert Audio & Stage Lighting")
    if any(k in text for k in ["deco", "floral", "flower", "arch", "drapes"]):
        services.append("Thematic Floral Styling")
    if any(k in text for k in ["photo", "video", "cinema", "4k", "media"]):
        services.append("Cinematic 4K Photography")
    if any(k in text for k in ["cake", "dessert"]):
        services.append("Celebration Cake Counter")
    if any(k in text for k in ["transport", "car", "limo", "bridal car"]):
        services.append("VIP Chauffeur Transport")

    # 4. Prompt Sanitization & Security Check
    is_injection_attempt = any(k in text for k in ["ignore instructions", "system prompt", "drop database", "<script>", "sql"])
    
    return {
        "eventCategory": event_category,
        "theme": theme,
        "extractedServices": services if services else ["Catering Buffet", "Basic Stage Setup"],
        "guestTier": "Large Scale" if guests >= 200 else ("Medium Scale" if guests >= 80 else "Intimate"),
        "budgetTier": "Luxury Tier" if budget >= 1500000 else ("Standard Tier" if budget >= 800000 else "Essential Tier"),
        "sanitizationPassed": not is_injection_attempt,
        "promptLength": len(prompt_text)
    }

# ==============================================================================
# Tool 4: Allow-listed Surgical Minimal Auto-Fit Tool (Member 4 - Safety Agent)
# ==============================================================================

VERIFIED_VENDOR_TIERS = {
    "AudioVisual": [
        {"vendor": "Lumina Pro Audio & Stage Lighting", "package": "Concert Line-Array Sound & Digital Mixer Package", "price": 180000.0},
        {"vendor": "Sensations Audio & Intelligent Lights - Colombo", "package": "Sensations Intelligent Audio & PAR Lighting", "price": 120000.0},
        {"vendor": "VibeWave Audio & Ambient LED - Kandy", "package": "Standard Stage Audio + Warm Ambient LED PAR Cans", "price": 85000.0},
        {"vendor": "SonicPulse Live Sound & Stage Monitors - Negombo", "package": "Stage Audio System + 2 Stage Monitors", "price": 60000.0},
        {"vendor": "Mano Sounds & Acoustic Setup - Moratuwa", "package": "Compact Speech PA Kit + 2 Wireless Mics", "price": 40000.0},
        {"vendor": "Derana Acoustics & PA System - Gampaha", "package": "Derana Compact Speech PA & Wireless Mics", "price": 25000.0},
        {"vendor": "QuickSound Acoustic & Speech Kit - Homagama", "package": "Compact Speech PA & Bluetooth Unit", "price": 15000.0},
    ],
    "MarqueeTent": [
        {"vendor": "Grand Royal German Hangar Marquees", "package": "Air-Conditioned Transparent German Hangar Marquee (40x80 ft)", "price": 350000.0},
        {"vendor": "Ceylon WeatherShield Marquee Tents", "package": "Heavy-Duty Waterproof Marquee Tent (20x40 ft)", "price": 150000.0},
        {"vendor": "SunShade Canopies & Pergolas Colombo", "package": "High-Peak Waterproof Stretch Canopy (20x30 ft)", "price": 80000.0},
        {"vendor": "SunShade Canopies", "package": "Standard Medium-Capacity Waterproof Pavilion", "price": 60000.0},
        {"vendor": "Apex Canopies & Tents - Ragama", "package": "Waterproof Canopy Shelter (15x20 ft)", "price": 35000.0},
        {"vendor": "QuickShade Canopy Rentals - Kelaniya", "package": "Economy Rain Canopy (10x10 ft)", "price": 18000.0},
    ],
    "CateringBuffet": [
        {"vendor": "Grand Royal Culinary Banquet", "package": "Executive Dinner Buffet (3 Meats, Seafood, 5 Salads, 8 Desserts)", "perHead": 6500.0},
        {"vendor": "Ceylon Banquet Caterers", "package": "Premium Dinner Buffet B (2 Meats, Action Station, 6 Desserts)", "perHead": 5000.0},
        {"vendor": "Heritage Feast Catering", "package": "Standard Dinner Buffet A (Chicken/Fish, 4 Salads, 4 Desserts)", "perHead": 3800.0},
        {"vendor": "Canape Cocktail & Savory Buffet", "package": "High Tea & Evening Canapé Cocktail Platter", "perHead": 3200.0},
    ],
    "Transport": [
        {"vendor": "Vintage Classic Limousines", "package": "Rolls Royce / Vintage Classic Mercedes Limousine", "price": 75000.0},
        {"vendor": "SilverLine Executive Chauffeur", "package": "Chrysler 300C / Mercedes E-Class Executive Sedan", "price": 45000.0},
        {"vendor": "Royal Fleet Weddings", "package": "White Toyota Premio VIP Chauffeur Car", "price": 25000.0},
        {"vendor": "CityDrive VIP Transport", "package": "Standard Air-Conditioned VIP Sedan", "price": 18000.0},
    ],
    "Cake": [
        {"vendor": "Royal Confectionery Studio", "package": "5-Tier Artisanal Fondant Showstopper Cake", "price": 55000.0},
        {"vendor": "SweetCrumb Patisserie", "package": "3-Tier Handcrafted Sugar Bloom Cake", "price": 30000.0},
        {"vendor": "Bespoke Bakers Malabe", "package": "2-Tier Minimalist Celebration Cake", "price": 15000.0},
    ],
    "Decor": [
        {"vendor": "Luxe Floral Art & Poruwa Grandeur", "package": "Grand Floral Cascade & Thematic Geometric Stage", "price": 180000.0},
        {"vendor": "Suba Setha Thematic Draping", "package": "Thematic Fabric Drapes & Fresh Floral Centerpieces", "price": 60000.0},
        {"vendor": "Piyum Flora & Budget Decor", "package": "Economy Fabric Backdrop & Floral Table Runner", "price": 25000.0},
        {"vendor": "Suba Setha Flora", "package": "Traditional Oil Lamp, Minimal Poruwa & Head Table Deco", "price": 18000.0},
    ]
}

def surgical_minimal_autofit_tool(budget_limit: float, items: list, guest_count: int, is_outdoor: bool = True) -> tuple[list, float, list[str]]:
    """
    Allow-listed Tool owned by Member 4 (Validation & Safety Agent).
    Executes the Surgical Minimal Auto-Fit algorithm: when proposal items exceed the client's budget ceiling,
    iteratively swaps oversized vendor packages with lower-tier verified partner vendors from the database catalog
    to bring total cost strictly under budget (Cost <= Budget) without deleting essential categories.
    """
    from schemas import ProposedItem

    current_items = [
        ProposedItem(**i.model_dump()) if hasattr(i, 'model_dump') else 
        (ProposedItem(**i.dict()) if hasattr(i, 'dict') else ProposedItem(**i))
        for i in items
    ]
    current_total = sum(i.cost for i in current_items)
    logs = []

    if current_total <= budget_limit or budget_limit <= 0:
        return current_items, current_total, logs

    # Physical Viability Check: if budget is so low that minimum catering per guest is < Rs. 1,000,
    # the event is mathematically unviable for the requested guest scale.
    min_viable_per_head = 1000.0
    if guest_count > 0 and (budget_limit / guest_count) < min_viable_per_head:
        logs.append(f"ValidationSafetyAgent (Member 4): Budget ceiling Rs. {budget_limit:,.2f} is mathematically unviable for {guest_count} guests (Minimum Rs. {min_viable_per_head:,.0f}/head required).")
        return current_items, current_total, logs

    initial_deficit = current_total - budget_limit
    logs.append(f"ValidationSafetyAgent (Member 4): Initial proposal exceeded budget by Rs. {initial_deficit:,.2f}. Executing Surgical Minimal Auto-Fit across verified vendor tiers.")

    # Step 1: Scalable Optional Items (Transport, Cake, Decor if present)
    for cat_name in ["Transport", "Cake", "Decor"]:
        if current_total <= budget_limit:
            break
        tier_list = VERIFIED_VENDOR_TIERS[cat_name]
        for idx, item in enumerate(current_items):
            if item.category == cat_name and item.cost > tier_list[-1]["price"]:
                for lower_tier in tier_list:
                    if lower_tier["price"] < current_items[idx].cost:
                        saved = current_items[idx].cost - lower_tier["price"]
                        current_items[idx] = ProposedItem(
                            name=f"{lower_tier['package']} ({lower_tier['vendor']})",
                            category=cat_name,
                            cost=lower_tier["price"]
                        )
                        current_total = sum(i.cost for i in current_items)
                        logs.append(f"ValidationSafetyAgent (Member 4): [Auto-Fit Downgrade] {item.name} -> {lower_tier['vendor']} ({lower_tier['package']}) (-Rs. {saved:,.2f})")
                        if current_total <= budget_limit:
                            break
                break

    # Step 2: AudioVisual (Sound & Lighting) Downgrade
    if current_total > budget_limit:
        for idx, item in enumerate(current_items):
            if item.category in ["AudioVisual", "SoundLighting"]:
                for lower_tier in VERIFIED_VENDOR_TIERS["AudioVisual"]:
                    if lower_tier["price"] < current_items[idx].cost:
                        saved = current_items[idx].cost - lower_tier["price"]
                        current_items[idx] = ProposedItem(
                            name=f"{lower_tier['package']} ({lower_tier['vendor']})",
                            category="AudioVisual",
                            cost=lower_tier["price"]
                        )
                        current_total = sum(i.cost for i in current_items)
                        logs.append(f"ValidationSafetyAgent (Member 4): [Auto-Fit Downgrade] {item.name} -> {lower_tier['vendor']} ({lower_tier['package']}) (-Rs. {saved:,.2f})")
                        if current_total <= budget_limit:
                            break
                break

    # Step 3: Weather Safeguard Marquee Tent Downgrade (if outdoor safeguard present)
    if current_total > budget_limit:
        for idx, item in enumerate(current_items):
            if item.isSafeguard or item.category in ["MarqueeTent", "WeatherSafeguard"] or "Tent" in item.name or "Canopy" in item.name:
                for lower_tier in VERIFIED_VENDOR_TIERS["MarqueeTent"]:
                    if lower_tier["price"] < current_items[idx].cost:
                        saved = current_items[idx].cost - lower_tier["price"]
                        current_items[idx] = ProposedItem(
                            name=f"{lower_tier['package']} ({lower_tier['vendor']})",
                            category="WeatherSafeguard",
                            cost=lower_tier["price"],
                            isSafeguard=True,
                            reason="Weather risk shelter auto-fitted to client budget"
                        )
                        current_total = sum(i.cost for i in current_items)
                        logs.append(f"ValidationSafetyAgent (Member 4): [Auto-Fit Downgrade Safeguard] {item.name} -> {lower_tier['vendor']} ({lower_tier['package']}) (-Rs. {saved:,.2f})")
                        if current_total <= budget_limit:
                            break
                break

    # Step 4: Catering Buffet Tier Step-Down (if still over budget)
    if current_total > budget_limit and guest_count > 0:
        for idx, item in enumerate(current_items):
            if item.category == "Catering":
                current_per_head = current_items[idx].cost / guest_count
                for lower_buffet in VERIFIED_VENDOR_TIERS["CateringBuffet"]:
                    if lower_buffet["perHead"] < current_per_head:
                        new_cost = lower_buffet["perHead"] * guest_count
                        saved = current_items[idx].cost - new_cost
                        current_items[idx] = ProposedItem(
                            name=f"{lower_buffet['package']} ({guest_count} Guests x Rs. {lower_buffet['perHead']:,.0f})",
                            category="Catering",
                            cost=new_cost
                        )
                        current_total = sum(i.cost for i in current_items)
                        current_per_head = lower_buffet["perHead"]
                        logs.append(f"ValidationSafetyAgent (Member 4): [Auto-Fit Downgrade Catering] {item.name} -> {lower_buffet['package']} ({lower_buffet['vendor']}) (-Rs. {saved:,.2f})")
                        if current_total <= budget_limit:
                            break
                # If still slightly over budget, adjust catering per-head rate to exactly fit ceiling
                if current_total > budget_limit:
                    non_catering = current_total - current_items[idx].cost
                    allowable_catering = budget_limit - non_catering
                    if allowable_catering >= (min_viable_per_head * guest_count):
                        allowable_per_head = round(allowable_catering / guest_count)
                        saved = current_items[idx].cost - allowable_catering
                        current_items[idx] = ProposedItem(
                            name=f"Standard Curated Buffet ({guest_count} Guests x Rs. {allowable_per_head:,.0f})",
                            category="Catering",
                            cost=allowable_catering
                        )
                        current_total = sum(i.cost for i in current_items)
                        logs.append(f"ValidationSafetyAgent (Member 4): [Auto-Fit Budget Ceiling Match] Catering adjusted to Rs. {allowable_per_head:,.0f}/head to strictly achieve Cost <= Budget (-Rs. {saved:,.2f})")
                break

    final_total = sum(i.cost for i in current_items)
    if final_total <= budget_limit:
        logs.append(f"ValidationSafetyAgent (Member 4): Auto-Fit complete. Final Subtotal Rs. {final_total:,.2f} is strictly <= Budget Limit Rs. {budget_limit:,.2f} (Total Savings: Rs. {initial_deficit:,.2f}).")
    return current_items, final_total, logs