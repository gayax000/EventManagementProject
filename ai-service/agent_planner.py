from schemas import EventObjectiveInput
from tools import extract_event_entities_tool

class PlanningAgent:
    """
    Owned by Member 2 (Kasun): Event Planning & Delegation Agent
    Decomposes natural language user goals into structured multi-step execution tasks
    using allow-listed NLP entity extraction tool.
    """
    def __init__(self):
        self.role_name = "Event Planning & Delegation Agent"

    def execute(self, objective: EventObjectiveInput) -> dict:
        prompt_input = objective.customPrompt or objective.title
        
        # 1. Execute Allow-listed NLP Entity Extraction Tool (Member 2 Distinct Tool)
        extracted = extract_event_entities_tool(
            prompt_text=prompt_input,
            title=objective.title,
            location=objective.location,
            budget=objective.budgetLimit,
            guests=objective.guestCount
        )

        trace_log = [
            f"PlannerAgent (Member 2): Initiating NLP entity extraction on objective '{objective.title}'",
            f"PlannerAgent (Member 2): Extracted Event Category: {extracted['eventCategory']} | Theme: {extracted['theme']}",
            f"PlannerAgent (Member 2): Target budget ceiling: Rs. {objective.budgetLimit:,.2f} for {objective.guestCount} guests ({extracted['guestTier']}, {extracted['budgetTier']}).",
            f"PlannerAgent (Member 2): Security Sanitization Check Passed: {extracted['sanitizationPassed']}"
        ]

        # 2. Dynamic Adaptive Task Decomposition (Based on extracted intent & theme)
        steps = [
            f"1. NLP Intent Analysis & Entity Extraction: Extracted category '{extracted['eventCategory']}' and '{extracted['theme']}' style preferences.",
            f"2. Environmental & Climate Risk Audit: Query weather tools for location '{objective.location}' on {objective.targetDate}.",
            f"3. Risk Safeguard Injection: Auto-inject structural marquee tent if rain probability exceeds threshold for outdoor grounds.",
            f"4. Resource Matching & Budget Optimization: Allocate venue and packages ({', '.join(extracted['extractedServices'])}) within Rs. {objective.budgetLimit:,.2f}.",
            f"5. Safety Gate & Human-in-the-Loop Interceptor: Enforce Cost <= Budget validation and route to Manager approval."
        ]

        return {
            "agent": self.role_name,
            "extractedEntities": extracted,
            "multiStepPlan": steps,
            "trace": trace_log
        }