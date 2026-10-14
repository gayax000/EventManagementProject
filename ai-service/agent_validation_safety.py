from typing import List
from schemas import EventObjectiveInput, ProposedItem
from tools import surgical_minimal_autofit_tool

class ValidationSafetyAgent:
    """
    Owned by Member 4: Deterministic Validation, Guardrails & Human Approval Interceptor
    Ensures budget constraints and schema validity via the Surgical Minimal Auto-Fit tool.
    """
    def __init__(self):
        self.role_name = "Deterministic Validation & Safety Agent"

    def execute(self, objective: EventObjectiveInput, subtotal: float, items: List[ProposedItem]) -> dict:
        trace_log = ["ValidationSafetyAgent (Member 4): Executing deterministic assertion rules and budget guardrails"]

        # Deterministic Rule 1: Budget Ceiling Constraint & Auto-Fit Tool
        if subtotal > objective.budgetLimit:
            fitted_items, fitted_subtotal, autofit_logs = surgical_minimal_autofit_tool(
                budget_limit=objective.budgetLimit,
                items=items,
                guest_count=objective.guestCount,
                is_outdoor=objective.isOutdoor
            )
            items = fitted_items
            subtotal = fitted_subtotal
            trace_log.extend(autofit_logs)

        is_under_budget = subtotal <= objective.budgetLimit
        remaining = objective.budgetLimit - subtotal

        # Deterministic Rule 2: Item Integrity Check
        has_items = len(items) > 0 and all(item.cost > 0 for item in items)

        passed = is_under_budget and has_items

        if passed:
            trace_log.append(f"ValidationSafetyAgent (Member 4): All deterministic safety rules PASSED. Subtotal: Rs. {subtotal:,.2f} <= Ceiling: Rs. {objective.budgetLimit:,.2f} (Remaining: Rs. {remaining:,.2f}).")
            trace_log.append("ValidationSafetyAgent (Member 4): Human-in-the-Loop Interceptor active. Routing proposal to Manager for review & sign-off.")
        else:
            trace_log.append(f"ValidationSafetyAgent (Member 4): VIOLATION - Proposal exceeds budget ceiling by Rs. {abs(remaining):,.2f}.")

        return {
            "agent": self.role_name,
            "items": items,
            "subtotal": subtotal,
            "isUnderBudget": is_under_budget,
            "budgetRemaining": remaining,
            "validationPassed": passed,
            "requiresHumanApproval": True,
            "approvalStatus": "PendingManagerApproval",
            "trace": trace_log
        }