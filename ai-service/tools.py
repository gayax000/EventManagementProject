import datetime

# Tool 1: Environmental & Weather Forecast Tool (Weather API Mock / Real Endpoint)
def check_weather_forecast(location: str, target_date: str) -> dict:
    """
    Allow-listed Tool: Retrieves environmental precipitation risk for event location and date.
    Hill country & coastal outdoor venues exhibit dynamic rain profiles.
    """
    loc_lower = location.lower()
    # Dynamic simulation matching Sri Lankan weather patterns
    if "nuwara" in loc_lower or "kandy" in loc_lower or "galle" in loc_lower:
        rain_probability = 75
        condition = "Heavy Monsoon Showers Expected"
        risk_level = "High"
    else:
        rain_probability = 25
        condition = "Mostly Sunny with Mild Breeze"
        risk_level = "Low"

    return {
        "location": location,
        "targetDate": target_date,
        "rainProbabilityPercent": rain_probability,
        "condition": condition,
        "riskLevel": risk_level,
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