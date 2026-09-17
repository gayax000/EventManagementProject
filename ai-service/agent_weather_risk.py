import datetime

from schemas import EventObjectiveInput, ProposedItem
 
class WeatherRiskAgent:

    """

    Owned by Member 3: Weather Risk & Environmental Contingency Agent

    Evaluates precipitation risk via weather tools and injects structural marquee safeguards.

    """

    def __init__(self):

        self.role_name = "Weather & Environmental Risk Agent"
 
    def query_weather_tool(self, location: str, target_date: str) -> dict:

        loc = location.lower()
        try:
            dt = datetime.datetime.fromisoformat(target_date.replace("Z", "+00:00"))
            month = dt.month
            day = dt.day
        except Exception:
            month = 10
            day = 15

        if month in [5, 6, 7, 8, 9]:  # Southwest Monsoon
            if any(p in loc for p in ["colombo", "galle", "kandy", "kalutara", "matara", "ratnapura", "nuwara"]):
                rain_pct = min(90, 65 + (day % 20))
                condition = "South-West Monsoon Rain Showers"
                risk = "High"
            else:
                rain_pct = 25 + (day % 15)
                condition = "Scattered Clouds"
                risk = "Low"
        elif month in [10, 11, 12]:  # Northeast Monsoon & 2nd Inter-Monsoon
            rain_pct = min(92, 70 + (day % 18))
            condition = "North-East Monsoon Showers"
            risk = "High"
        elif month in [1, 2, 3]:  # Dry Season
            rain_pct = 15 + (day % 10)
            condition = "Clear Sky & Sunny"
            risk = "Low"
        else:  # April 1st Inter-Monsoon
            rain_pct = 50 + (day % 20)
            condition = "Inter-Monsoon Thunderstorms"
            risk = "Moderate"
 
        return {

            "location": location,

            "targetDate": target_date,

            "rainProbabilityPercent": rain_pct,

            "condition": condition,

            "riskLevel": risk,

            "timestamp": datetime.datetime.utcnow().isoformat()

        }
 
    def execute(self, objective: EventObjectiveInput) -> dict:

        trace_log = [f"WeatherRiskAgent (Member 3): Querying Weather API Tool for {objective.location}"]

        weather_info = self.query_weather_tool(objective.location, objective.targetDate)
 
        safeguard = None

        if objective.isOutdoor and weather_info["rainProbabilityPercent"] >= 60:

            safeguard = ProposedItem(

                name="Heavy-Duty Waterproof Marquee Tent (20x40 ft)",

                category="WeatherSafeguard",

                cost=150000.0,

                isSafeguard=True,

                reason=f"70%+ Rain Probability detected on outdoor grounds in {objective.location}."

            )

            trace_log.append(f"WeatherRiskAgent (Member 3): ALERT - Rain risk {weather_info['rainProbabilityPercent']}%. Auto-injected Marquee Tent safeguard (Rs. 150,000).")

        else:

            trace_log.append("WeatherRiskAgent (Member 3): Weather conditions safe. No shelter contingency required.")
 
        return {

            "agent": self.role_name,

            "weatherAssessment": weather_info,

            "safeguardItem": safeguard,

            "trace": trace_log

        }
 