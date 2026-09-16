from schemas import EventObjectiveInput

class PlanningAgent:
    """
    Owned by Member 2 (Kasun): Event Planning & Delegation Agent
    Decomposes natural language user goals into structured multi-step execution tasks.
    """
    def __init__(self):
        self.role_name = "Event Planning & Delegation Agent"

    def execute(self, objective: EventObjectiveInput) -> dict:
        trace_log = [
            f"PlannerAgent (Member 2): Initiating task decomposition for '{objective.title}'",
            f"PlannerAgent (Member 2): Target budget ceiling: Rs. {objective.budgetLimit:,.2f} for {objective.guestCount} guests."
        ]

        steps = [
            "1. Weather & Environmental Assessment: Query weather tools for target location",
            "2. Risk Mitigation: Auto-inject structural safeguards if precipitation exceeds safety thresholds",
            "3. Resource Matching & Budget Optimization: Query inventory tools for catering and sound packages",
            "4. Safety Gate & Human-in-the-Loop: Enforce deterministic constraints and request Manager approval"
        ]

        return {
            "agent": self.role_name,
            "multiStepPlan": steps,
            "trace": trace_log
        }