from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uuid

from schemas import EventObjectiveInput, AgentWorkflowResult
from agent_planner import PlanningAgent

# Try importing other agents; fallback gracefully if members haven't pushed yet
try:
    from agent_weather_risk import WeatherRiskAgent
except ImportError:
    WeatherRiskAgent = None

try:
    from agent_resource_optimizer import ResourceOptimizerAgent
except ImportError:
    ResourceOptimizerAgent = None

try:
    from agent_validation_safety import ValidationSafetyAgent
except ImportError:
    ValidationSafetyAgent = None

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
    return {"status": "Online", "engine": "EventCraft Multi-Agent AI Subsystem"}

@app.post("/api/ai/plan", response_model=AgentWorkflowResult)
def execute_multi_agent_workflow(event_req: EventObjectiveInput):
    """
    Coordinates the 4 Member Agents:
    1. Member 2: Planning & Delegation Agent
    2. Member 3: Weather Risk & Safeguard Agent
    3. Member 1: Resource & Budget Optimization Agent
    4. Member 4: Deterministic Validation & Safety Agent
    """
    try:
        workflow_id = str(uuid.uuid4())
        audit_trace = []

        # 1. Member 2 (Kasun): Planning Agent
        planner = PlanningAgent()
        plan_res = planner.execute(event_req)
        audit_trace.extend(plan_res["trace"])

        # 2. Member 3: Weather Risk Agent
        if WeatherRiskAgent:
            weather_agent = WeatherRiskAgent()
            weather_res = weather_agent.execute(event_req)
            audit_trace.extend(weather_res["trace"])
            weather_assessment = weather_res["weatherAssessment"]
            safeguard_item = weather_res["safeguardItem"]
        else:
            weather_assessment = {"rainProbabilityPercent": 75, "condition": "Monsoon Rain Alert"}
            safeguard_item = None
            audit_trace.append("WeatherRiskAgent: Fallback simulation active.")

        # 3. Member 1: Resource Optimizer Agent
        if ResourceOptimizerAgent:
            resource_agent = ResourceOptimizerAgent()
            resource_res = resource_agent.execute(event_req, safeguard_item)
            audit_trace.extend(resource_res["trace"])
            selected_venue = resource_res["selectedVenue"]
            items = resource_res["items"]
            subtotal = resource_res["subtotal"]
        else:
            selected_venue = "The Grand Hotel Nuwara Eliya"
            items = []
            subtotal = 800000.0
            audit_trace.append("ResourceOptimizerAgent: Fallback simulation active.")

        # 4. Member 4: Deterministic Validation & Safety Agent
        if ValidationSafetyAgent:
            validator = ValidationSafetyAgent()
            val_res = validator.execute(event_req, subtotal, items)
            audit_trace.extend(val_res["trace"])
            is_under_budget = val_res["isUnderBudget"]
            remaining = val_res["budgetRemaining"]
            validation_passed = val_res["validationPassed"]
            requires_human_approval = val_res["requiresHumanApproval"]
            approval_status = val_res["approvalStatus"]
        else:
            is_under_budget = subtotal <= event_req.budgetLimit
            remaining = event_req.budgetLimit - subtotal
            validation_passed = is_under_budget
            requires_human_approval = True
            approval_status = "PendingManagerApproval"
            audit_trace.append("ValidationSafetyAgent: Fallback validation checks passed.")

        return AgentWorkflowResult(
            workflowId=workflow_id,
            eventId=event_req.eventId,
            objectiveSummary=f"Multi-agent proposal for {event_req.title} with {event_req.guestCount} guests in {event_req.location}",
            multiStepPlan=plan_res["multiStepPlan"],
            weatherRiskAssessment=weather_assessment,
            selectedVenue=selected_venue,
            costBreakdown=items,
            subtotal=subtotal,
            isUnderBudget=is_under_budget,
            budgetRemaining=remaining,
            validationPassed=validation_passed,
            requiresHumanApproval=requires_human_approval,
            approvalStatus=approval_status,
            auditTraceLogs=audit_trace
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Orchestration failure: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)