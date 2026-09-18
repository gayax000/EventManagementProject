import datetime
from schemas import EventObjectiveInput, ProposedItem
from tools import check_weather_forecast

class WeatherRiskAgent:
    """
    Owned by Member 3: Weather Risk & Environmental Contingency Agent
    Evaluates precipitation risk via live OpenWeatherMap tool or monsoon fallback and injects structural marquee safeguards.
    """

    def __init__(self):
        self.role_name = "Weather & Environmental Risk Agent"

    def execute(self, objective: EventObjectiveInput) -> dict:
        trace_log = [f"WeatherRiskAgent (Member 3): Querying Weather API Tool for '{objective.location}'"]

        weather_info = check_weather_forecast(objective.location, objective.targetDate)

        source = weather_info.get("source", "Weather Tool")
        rain_pct = weather_info.get("rainProbabilityPercent", 0)
        condition = weather_info.get("condition", "")

        trace_log.append(f"WeatherRiskAgent (Member 3): Forecast loaded via [{source}]. Condition: '{condition}', Rain Risk: {rain_pct}%.")

        safeguard = None

        if objective.isOutdoor and rain_pct >= 60:
            safeguard = ProposedItem(
                name="Heavy-Duty Waterproof Marquee Tent (20x40 ft)",
                category="WeatherSafeguard",
                cost=150000.0,
                isSafeguard=True,
                reason=f"{rain_pct}% Rain Probability detected via [{source}] for outdoor grounds in {objective.location}."
            )
            trace_log.append(f"WeatherRiskAgent (Member 3): ALERT - Rain risk {rain_pct}% >= 60%. Auto-injected Marquee Tent safeguard (Rs. 150,000).")
        else:
            trace_log.append("WeatherRiskAgent (Member 3): Weather conditions safe or event is indoor. No marquee shelter safeguard required.")

        return {
            "agent": self.role_name,
            "weatherAssessment": weather_info,
            "safeguardItem": safeguard,
            "trace": trace_log
        }