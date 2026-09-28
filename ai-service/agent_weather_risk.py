from schemas import EventObjectiveInput, ProposedItem
import tools

class WeatherRiskAgent:
    """
    Owned by Member 3: Weather Risk & Environmental Contingency Agent
    Evaluates precipitation risk via allow-listed weather tool (Live OpenWeather API with 
    historical seasonal fallback) and injects structural marquee safeguards when precipitation >= 60%.
    """

    def __init__(self):
        self.role_name = "Weather & Environmental Risk Agent"

    def execute(self, objective: EventObjectiveInput) -> dict:
        trace_log = [f"WeatherRiskAgent (Member 3): Querying allow-listed Weather Tool for '{objective.location}'"]

        weather_info = tools.check_weather_forecast(objective.location, objective.targetDate)
        
        data_source = weather_info.get("dataSource", "Weather Tool")
        rain_pct = weather_info.get("rainProbabilityPercent", 0)
        condition = weather_info.get("condition", "Variable")
        city = weather_info.get("city", objective.location)

        trace_log.append(f"WeatherRiskAgent (Member 3): Source: [{data_source}] for {city}. Rain Probability: {rain_pct}% ({condition})")

        safeguard = None
        if objective.isOutdoor and rain_pct >= 60:
            safeguard = ProposedItem(
                name="Heavy-Duty Waterproof Marquee Tent (20x40 ft)",
                category="WeatherSafeguard",
                cost=150000.0,
                isSafeguard=True,
                reason=f"{rain_pct}% Rain Probability detected for outdoor grounds in {city} via {data_source}."
            )
            trace_log.append(f"WeatherRiskAgent (Member 3): ALERT - Rain risk {rain_pct}% exceeds safety threshold (60%). Auto-injected Marquee Tent safeguard (Rs. 150,000).")
        else:
            if not objective.isOutdoor:
                trace_log.append("WeatherRiskAgent (Member 3): Event is indoors. 0% weather exposure; no shelter contingency required.")
            else:
                trace_log.append(f"WeatherRiskAgent (Member 3): Precipitation risk within safe limits ({rain_pct}%). No structural safeguard required.")

        return {
            "agent": self.role_name,
            "weatherAssessment": weather_info,
            "safeguardItem": safeguard,
            "trace": trace_log
        }