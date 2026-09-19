import unittest
from schemas import EventObjectiveInput
from agent_weather_risk import WeatherRiskAgent
from main import execute_multi_agent_workflow

class TestAgenticAIEvaluation(unittest.TestCase):
    """
    SLIIT SE3090 Section 9 & 12 Compliant Agentic AI Evaluation Suite.
    Executes rule-based assertions and golden cases on multi-agent execution.
    """

    def test_distinct_four_agents_presence_in_audit_trace(self):
        req = EventObjectiveInput(
            title="Corporate Annual Gala 2026",
            guestCount=200,
            budgetLimit=2500000.0,
            location="Colombo",
            isOutdoor=False,
            targetDate="2026-11-15"
        )
        res = execute_multi_agent_workflow(req)
        trace_str = " ".join(res.auditTraceLogs)

        # Verify 4 distinct agent roles participating in workflow
        self.assertIn("PlannerAgent (Member 2)", trace_str)
        self.assertIn("WeatherRiskAgent (Member 3)", trace_str)
        self.assertIn("ResourceOptimizerAgent (Member 1)", trace_str)
        self.assertIn("ValidationSafetyAgent (Member 4)", trace_str)

    def test_outdoor_event_high_rain_risk_auto_injects_marquee_tent(self):
        agent = WeatherRiskAgent()
        outdoor_req = EventObjectiveInput(
            title="Beachside Outdoor Celebration",
            guestCount=150,
            budgetLimit=2000000.0,
            location="Kandy",
            isOutdoor=True,
            targetDate="2026-10-15"
        )
        res = agent.execute(outdoor_req)
        
        # Verify precipitation risk >= 60% triggers Marquee Tent safeguard
        self.assertIsNotNone(res["safeguardItem"])
        self.assertEqual(res["safeguardItem"].name, "Heavy-Duty Waterproof Marquee Tent (20x40 ft)")
        self.assertEqual(res["safeguardItem"].cost, 150000.0)

    def test_indoor_event_high_rain_risk_does_not_inject_tent(self):
        agent = WeatherRiskAgent()
        indoor_req = EventObjectiveInput(
            title="Ballroom Indoor Reception",
            guestCount=150,
            budgetLimit=2000000.0,
            location="Kandy",
            isOutdoor=False,
            targetDate="2026-10-15"
        )
        res = agent.execute(indoor_req)
        
        # Verify indoor event does not require marquee shelter safeguard
        self.assertIsNone(res["safeguardItem"])

    def test_budget_guardrails_validation_assertion(self):
        over_budget_req = EventObjectiveInput(
            title="Over Budget Luxury Event",
            guestCount=1000,
            budgetLimit=500000.0,
            location="Colombo",
            isOutdoor=False,
            targetDate="2026-12-01"
        )
        res = execute_multi_agent_workflow(over_budget_req)
        
        # Verify ValidationSafetyAgent flags budget violation
        self.assertFalse(res.isUnderBudget)
        self.assertFalse(res.validationPassed)

if __name__ == '__main__':
    unittest.main()
