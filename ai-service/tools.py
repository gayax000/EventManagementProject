import os
import datetime
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

    return {
        "rainProbabilityPercent": rain_probability,
        "condition": condition,
        "riskLevel": risk_level,
        "dataSource": f"Historical Sri Lanka Seasonal Climate Model ({season_name})"
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
            # 1. Query hyper-local town first
            url = f"https://api.openweathermap.org/data/2.5/forecast?q={city},LK&appid={PRIMARY_API_KEY}&units=metric"
            response = requests.get(url, timeout=5.0)

            # 2. If town lookup returns 404, gracefully fallback to District capital
            if response.status_code != 200 and district and district.lower() != city.lower():
                fallback_url = f"https://api.openweathermap.org/data/2.5/forecast?q={district},LK&appid={PRIMARY_API_KEY}&units=metric"
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
                        "condition": weather_desc,
                        "riskLevel": risk_level,
                        "dataSource": "Live OpenWeatherMap 5-Day Forecast API",
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
        "condition": seasonal_data["condition"],
        "riskLevel": seasonal_data["riskLevel"],
        "dataSource": seasonal_data["dataSource"],
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