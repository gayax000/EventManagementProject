from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uuid
import traceback

from langgraph.graph import StateGraph, START, END

from schemas import EventObjectiveInput, AgentWorkflowResult, AgentGraphState
from agent_planner import PlanningAgent
from agent_weather_risk import WeatherRiskAgent
from agent_resource_optimizer import ResourceOptimizerAgent
from agent_validation_safety import ValidationSafetyAgent

app = FastAPI(
    title="EventCraft Multi-Agent AI Subsystem (LangGraph)",
    description="Multi-Agent Orchestrator powered by LangGraph, compliant with SLIIT SE3090 Assignment 1",
    version="2.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# 1. Instantiate 4 Specialized Domain Agents (1 per group member)
# ---------------------------------------------------------------------------
planner_agent = PlanningAgent()                       # Member 2 (Kasun): Planning & Task Decomposition
weather_agent = WeatherRiskAgent()                     # Member 3: Weather Risk & Safeguard Tool
optimizer_agent = ResourceOptimizerAgent()             # Member 1: Resource & Budget Optimizer
safety_agent = ValidationSafetyAgent()                 # Member 4: Deterministic Validation & Human Gate

# ---------------------------------------------------------------------------
# 2. Define LangGraph Node Functions (State Transitions)
# ---------------------------------------------------------------------------
def planner_node(state: AgentGraphState) -> dict:
    """Node 1 (Member 2): Decomposes natural language objective into structured multi-step execution tasks."""
    res = planner_agent.execute(state["objective"])
    logs = list(state.get("audit_trace_logs", [])) + res["trace"]
    return {
        "multi_step_plan": res["multiStepPlan"],
        "audit_trace_logs": logs
    }

def weather_risk_node(state: AgentGraphState) -> dict:
    """Node 2 (Member 3): Evaluates real-time / seasonal precipitation risk via allow-listed weather tool."""
    res = weather_agent.execute(state["objective"])
    logs = list(state.get("audit_trace_logs", [])) + res["trace"]
    return {
        "weather_assessment": res["weatherAssessment"],
        "safeguard_item": res["safeguardItem"],
        "audit_trace_logs": logs
    }

def resource_optimizer_node(state: AgentGraphState) -> dict:
    """Node 3 (Member 1): Matches venue, catering buffet, and sound packages under client budget."""
    res = optimizer_agent.execute(state["objective"], state.get("safeguard_item"))
    logs = list(state.get("audit_trace_logs", [])) + res["trace"]
    return {
        "selected_venue": res["selectedVenue"],
        "cost_breakdown": res["items"],
        "subtotal": res["subtotal"],
        "audit_trace_logs": logs
    }

def validation_safety_node(state: AgentGraphState) -> dict:
    """Node 4 (Member 4): Deterministic guardrails (cost <= budget) and human approval interceptor."""
    res = safety_agent.execute(state["objective"], state.get("subtotal", 0.0), state.get("cost_breakdown", []))
    logs = list(state.get("audit_trace_logs", [])) + res["trace"]
    return {
        "is_under_budget": res["isUnderBudget"],
        "budget_remaining": res["budgetRemaining"],
        "validation_passed": res["validationPassed"],
        "requires_human_approval": res["requiresHumanApproval"],
        "approval_status": res["approvalStatus"],
        "audit_trace_logs": logs
    }

# ---------------------------------------------------------------------------
# 3. Construct and Compile LangGraph StateGraph (SE3090 Section 9 & 10)
# ---------------------------------------------------------------------------
workflow = StateGraph(AgentGraphState)

# Add the 4 Distinct Agent Nodes
workflow.add_node("planner_agent", planner_node)
workflow.add_node("weather_risk_agent", weather_risk_node)
workflow.add_node("resource_optimizer_agent", resource_optimizer_node)
workflow.add_node("validation_safety_agent", validation_safety_node)

# Set Entry Point and Linear / Sequential State Transitions
workflow.set_entry_point("planner_agent")
workflow.add_edge("planner_agent", "weather_risk_agent")
workflow.add_edge("weather_risk_agent", "resource_optimizer_agent")
workflow.add_edge("resource_optimizer_agent", "validation_safety_agent")
workflow.add_edge("validation_safety_agent", END)

# Compile Executable Multi-Agent Graph
agent_graph = workflow.compile()

# ---------------------------------------------------------------------------
# 4. REST API Endpoints (Exposed to ASP.NET Core Web API)
# ---------------------------------------------------------------------------
@app.get("/health")
def health_check():
    return {
        "status": "Online",
        "service": "EventCraft Multi-Agent AI Subsystem (LangGraph)",
        "framework": "LangGraph StateGraph",
        "nodes": ["planner_agent", "weather_risk_agent", "resource_optimizer_agent", "validation_safety_agent"],
        "agents": [
            planner_agent.role_name,
            weather_agent.role_name,
            optimizer_agent.role_name,
            safety_agent.role_name
        ]
    }

@app.post("/api/ai/plan", response_model=AgentWorkflowResult)
def execute_multi_agent_workflow(event_req: EventObjectiveInput):
    """
    Executes the LangGraph Multi-Agent Orchestrator across the 4 specialized agent roles.
    Input contract and Output response remain 100% compliant with ASP.NET Core & React/Flutter.
    """
    try:
        workflow_id = str(uuid.uuid4())

        initial_state: AgentGraphState = {
            "workflow_id": workflow_id,
            "objective": event_req,
            "audit_trace_logs": []
        }

        # Invoke the LangGraph State Machine
        final_state = agent_graph.invoke(initial_state)

        return AgentWorkflowResult(
            workflowId=workflow_id,
            eventId=event_req.eventId,
            objectiveSummary=f"Autonomous plan for {event_req.title} with {event_req.guestCount} guests in {event_req.location}",
            multiStepPlan=final_state.get("multi_step_plan", []),
            weatherRiskAssessment=final_state.get("weather_assessment", {}),
            selectedVenue=final_state.get("selected_venue", ""),
            costBreakdown=final_state.get("cost_breakdown", []),
            subtotal=final_state.get("subtotal", 0.0),
            isUnderBudget=final_state.get("is_under_budget", False),
            budgetRemaining=final_state.get("budget_remaining", 0.0),
            validationPassed=final_state.get("validation_passed", False),
            requiresHumanApproval=final_state.get("requires_human_approval", True),
            approvalStatus=final_state.get("approval_status", "PendingManagerApproval"),
            auditTraceLogs=final_state.get("audit_trace_logs", [])
        )

    except Exception as e:
        print("AGENT WORKFLOW ERROR:", traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"LangGraph Orchestration failure: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)