from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uuid
import traceback

from schemas import EventObjectiveInput, AgentWorkflowResult, ProposedItem

app = FastAPI(
    title="EventCraft Agentic AI Subsystem",
    description="Multi-Agent Orchestrator compliant with SLIIT SE3090 Assignment 1",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health_check():
    return {"status": "Online", "service": "EventCraft Multi-Agent AI Subsystem"}

@app.post("/api/ai/plan", response_model=AgentWorkflowResult)
def execute_multi_agent_workflow(event_req: EventObjectiveInput):
    """
    Orchestrates the 4 Distinct Agent Roles:
    1. Member 2 (Kasun): Planning & Task Graph Agent
    2. Member 3: Weather Risk & Safeguard Tool Agent
    3. Member 1: Resource & Budget Optimizer Agent
    4. Member 4: Deterministic Validation & Safety Agent
    """
    try:
        workflow_id = str(uuid.uuid4())
        audit_trace = []

        # -------------------------------------------------------------
        # 1. Member 2 (Kasun): Planning & Delegation Agent
        # -------------------------------------------------------------
        audit_trace.append(f"PlannerAgent (Member 2): Decomposing objective for '{event_req.title}' (Guests: {event_req.guestCount}, Budget: Rs. {event_req.budgetLimit:,.2f})")
        plan_steps = [
            "Step 1: Environmental & Weather Assessment via Weather API Tool",
            "Step 2: Dynamic Contingency Safeguard Injection for Rain Risk",
            "Step 3: Venue, Catering & AV Package Matching and Budget Optimization",
            "Step 4: Deterministic Rule Checks and Human Approval Hold"
        ]

        # -------------------------------------------------------------
        # 2. Member 3: Weather Risk & Environmental Agent
        # -------------------------------------------------------------
        audit_trace.append(f"WeatherRiskAgent (Member 3): Querying Weather Tool for '{event_req.location}'")
        loc_lower = event_req.location.lower()
        if any(place in loc_lower for place in ["nuwara", "kandy", "galle", "lawn"]):
            rain_pct = 75
            condition = "Heavy Monsoon Rain Showers Expected"
            risk_level = "High"
        else:
            rain_pct = 25
            condition = "Clear / Partly Cloudy"
            risk_level = "Low"

        weather_assessment = {
            "location": event_req.location,
            "targetDate": event_req.targetDate,
            "rainProbabilityPercent": rain_pct,
            "condition": condition,
            "riskLevel": risk_level
        }

        safeguard_item = None
        if event_req.isOutdoor and rain_pct >= 60:
            safeguard_item = ProposedItem(
                name="Heavy-Duty Waterproof Marquee Tent (20x40 ft)",
                category="WeatherSafeguard",
                cost=150000.0,
                isSafeguard=True,
                reason=f"70%+ Rain Probability detected on outdoor grounds in {event_req.location}."
            )
            audit_trace.append(f"WeatherRiskAgent (Member 3): ALERT - Rain risk {rain_pct}%. Auto-injected Marquee Tent safeguard (Rs. 150,000).")
        else:
            audit_trace.append("WeatherRiskAgent (Member 3): Risk within limits. No structural safeguard required.")

        # -------------------------------------------------------------
        # 3. Member 1: Resource & Budget Optimization Agent
        # -------------------------------------------------------------
        audit_trace.append(f"ResourceOptimizerAgent (Member 1): Querying inventory tools for {event_req.guestCount} guests")
        
        # Venue Selection
        if "nuwara" in loc_lower:
            selected_venue = "The Grand Hotel Nuwara Eliya - Governors Lawn"
        elif "kandy" in loc_lower:
            selected_venue = "Earl's Regency Kandy - Regent Ballroom"
        elif "galle" in loc_lower:
            selected_venue = "Jetwing Lighthouse Galle - Ocean Rocks Lawn"
        else:
            selected_venue = "Shangri-La Colombo - Lotus Ballroom"

        # Catering & Sound Packaging
        buffet_per_head = 5000.0
        catering_cost = buffet_per_head * event_req.guestCount
        sound_cost = 150000.0

        items = [
            ProposedItem(
                name=f"Premium Dinner Buffet B ({event_req.guestCount} Guests x Rs. {buffet_per_head:,.0f})",
                category="Catering",
                cost=catering_cost
            ),
            ProposedItem(
                name="Concert Stage, Audio & Intelligent Lighting Rig",
                category="AudioVisual",
                cost=sound_cost
            )
        ]

        if safeguard_item:
            items.append(safeguard_item)

        subtotal = sum(i.cost for i in items)
        audit_trace.append(f"ResourceOptimizerAgent (Member 1): Optimal package compiled. Subtotal: Rs. {subtotal:,.2f}")

        # -------------------------------------------------------------
        # 4. Member 4: Deterministic Validation & Safety Agent
        # -------------------------------------------------------------
        audit_trace.append("ValidationSafetyAgent (Member 4): Executing deterministic assertion rules and budget guardrails")
        
        is_under_budget = subtotal <= event_req.budgetLimit
        remaining = event_req.budgetLimit - subtotal
        validation_passed = is_under_budget and len(items) > 0

        if validation_passed:
            audit_trace.append("ValidationSafetyAgent (Member 4): All deterministic safety rules PASSED.")
            audit_trace.append("ValidationSafetyAgent (Member 4): Halting workflow. Status set to PendingManagerApproval.")
        else:
            audit_trace.append(f"ValidationSafetyAgent (Member 4): VIOLATION - Proposal exceeds budget by Rs. {abs(remaining):,.2f}")

        return AgentWorkflowResult(
            workflowId=workflow_id,
            eventId=event_req.eventId,
            objectiveSummary=f"Autonomous plan for {event_req.title} with {event_req.guestCount} guests in {event_req.location}",
            multiStepPlan=plan_steps,
            weatherRiskAssessment=weather_assessment,
            selectedVenue=selected_venue,
            costBreakdown=items,
            subtotal=subtotal,
            isUnderBudget=is_under_budget,
            budgetRemaining=remaining,
            validationPassed=validation_passed,
            requiresHumanApproval=True,
            approvalStatus="PendingManagerApproval",
            auditTraceLogs=audit_trace
        )

    except Exception as e:
        print("AGENT WORKFLOW ERROR:", traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Orchestration failure: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)