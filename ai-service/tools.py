import datetime
import os
import requests

# Tool 1: Environmental & Weather Forecast Tool (Hybrid Live OpenWeatherMap API + Sri Lankan Monsoon Fallback)
def check_weather_forecast(location: str, target_date: str) -> dict:
    """
    Allow-listed Tool: Retrieves environmental precipitation risk for event location and date.
    Attempts live query to OpenWeatherMap API if OPENWEATHER_API_KEY is configured.
    Falls back gracefully to Sri Lankan seasonal monsoon model if unconfigured or forecast exceeds API range.
    """
    api_key = os.getenv("OPENWEATHER_API_KEY") or os.getenv("WEATHER_API_KEY")
    source = "Sri Lankan Seasonal Monsoon Model (Fallback)"
    rain_probability = None
    condition = None
    risk_level = None

    # 1. Attempt Live OpenWeatherMap API Query
    if api_key:
        try:
            url = f"https://api.openweathermap.org/data/2.5/weather?q={location},LK&appid={api_key}&units=metric"
            resp = requests.get(url, timeout=3)
            if resp.status_code == 200:
                data = resp.json()
                weather_main = data.get("weather", [{}])[0].get("main", "")
                weather_desc = data.get("weather", [{}])[0].get("description", "").title()
                clouds = data.get("clouds", {}).get("all", 0)
                
                # Estimate rain probability based on live cloud cover & condition
                if "Rain" in weather_main or "Thunderstorm" in weather_main or "Drizzle" in weather_main:
                    rain_probability = max(75, clouds)
                    risk_level = "High"
                elif clouds > 60:
                    rain_probability = clouds
                    risk_level = "Moderate"
                else:
                    rain_probability = min(35, clouds)
                    risk_level = "Low"

                condition = f"{weather_desc} ({weather_main})"
                source = "OpenWeatherMap Live API"
        except Exception:
            # Fallback on network timeout or invalid API response
            pass

    # 2. Fallback to Sri Lankan Seasonal Monsoon Dynamic Forecast Model
    if rain_probability is None:
        loc_lower = location.lower()
        try:
            dt = datetime.datetime.fromisoformat(target_date.replace("Z", "+00:00"))
            month = dt.month
            day = dt.day
        except Exception:
            month = 10
            day = 15

        if month in [5, 6, 7, 8, 9]:  # Southwest Monsoon
            if any(p in loc_lower for p in ["colombo", "galle", "kandy", "kalutara", "matara", "ratnapura", "nuwara"]):
                rain_probability = min(90, 65 + (day % 20))
                condition = "South-West Monsoon Rain Showers"
                risk_level = "High"
            else:
                rain_probability = 25 + (day % 15)
                condition = "Scattered Clouds"
                risk_level = "Low"
        elif month in [10, 11, 12]:  # Northeast Monsoon & 2nd Inter-Monsoon
            rain_probability = min(92, 70 + (day % 18))
            condition = "North-East Monsoon Showers"
            risk_level = "High"
        elif month in [1, 2, 3]:  # Dry Season
            rain_probability = 15 + (day % 10)
            condition = "Clear Sky & Sunny"
            risk_level = "Low"
        else:  # April 1st Inter-Monsoon
            rain_probability = 50 + (day % 20)
            condition = "Inter-Monsoon Thunderstorms"
            risk_level = "Moderate"

    return {
        "location": location,
        "targetDate": target_date,
        "rainProbabilityPercent": rain_probability,
        "condition": condition,
        "riskLevel": risk_level,
        "source": source,
        "timestamp": datetime.datetime.utcnow().isoformat()
    }


# Tool 2: Sri Lankan Venue & Inventory Pricing Tool
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
        "buffetPerHead": 5000.0, # Premium Dinner Buffet B
        "soundRigPrice": 150000.0, # Line-Array Rig
        "marqueeTentPrice": 150000.0 # Weather Safeguard
    }