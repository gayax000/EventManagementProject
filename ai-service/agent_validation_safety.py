from typing import List
from schemas import EventObjectiveInput, ProposedItem

class ValidationSafetyAgent:
    """
    Owned by Member 4: Deterministic Validation, Guardrails & Human Approval Interceptor
    Ensures budget constraints and schema validity, halting the workflow for Manager Review.
    """
    def _init_(self):
        self.role_name = "Deterministic Validation & Safety Agent"

    def execute(self, objective: EventObjectiveInput, subtotal: float, items: List[ProposedItem]) -> dict:
        trace_log = ["ValidationSafetyAgent (Member 4): Executing deterministic assertion rules and budget guardrails"]

        # Deterministic Rule 1: Budget Ceiling Constraint
        is_under_budget = subtotal <= objective.budgetLimit
        remaining = objective.budgetLimit - subtotal

        # Deterministic Rule 2: Item Integrity Check
        has_items = len(items) > 0 and all(item.cost > 0 for item in items)

        passed = is_under_budget and has_items

        if passed:
            trace_log.append("ValidationSafetyAgent (Member 4): All deterministic safety rules PASSED.")
            trace_log.append("ValidationSafetyAgent (Member 4): Halting workflow. Setting state to PendingManagerApproval.")
        else:
            trace_log.append(f"ValidationSafetyAgent (Member 4): VIOLATION - Proposal exceeds budget by Rs. {abs(remaining):,.2f}")

        return {
            "agent": self.role_name,
            "isUnderBudget": is_under_budget,
            "budgetRemaining": remaining,
            "validationPassed": passed,
            "requiresHumanApproval": True,
            "approvalStatus": "PendingManagerApproval",
            "trace": trace_log
        }