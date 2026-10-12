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
            budget = objective.budgetLimit
            if budget > 2000000.0:
                tent_name = "Air-Conditioned Transparent German Hangar Marquee (40x80 ft)"
                tent_cost = 350000.0
                tent_partner = "Grand Royal German Hangar Marquees"
            elif budget >= 1200000.0:
                tent_name = "Heavy-Duty Waterproof Marquee Tent (20x40 ft)"
                tent_cost = 150000.0
                tent_partner = "Ceylon WeatherShield Marquee Tents"
            elif budget >= 700000.0:
                tent_name = "High-Peak Waterproof Stretch Canopy (20x30 ft)"
                tent_cost = 80000.0
                tent_partner = "SunShade Canopies & Pergolas Colombo"
            else:
                tent_name = "Waterproof Pagoda / Rain Shelter Canopy (15x15 ft)"
                tent_cost = 45000.0
                tent_partner = "Apex Canopies & Tents - Ragama"

            safeguard = ProposedItem(
                name=tent_name,
                category="WeatherSafeguard",
                cost=tent_cost,
                isSafeguard=True,
                reason=f"{rain_pct}% Rain Probability detected for outdoor grounds in {city} via {data_source}.",
                partner=tent_partner
            )
            trace_log.append(
                f"WeatherRiskAgent (Member 3): ALERT - Rain risk {rain_pct}% exceeds safety threshold (60%). "
                f"Auto-injected tiered safeguard: {tent_name} (Rs. {tent_cost:,.0f}) [Partner: {tent_partner}]."
            )
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