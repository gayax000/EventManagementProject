from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from typing_extensions import TypedDict
import uuid

# 1. User Event Request Input Contract
class EventObjectiveInput(BaseModel):
    eventId: str = Field(default_factory=lambda: str(uuid.uuid4()))
    title: str
    targetDate: str
    guestCount: int = Field(gt=0, description="Number of guests")
    budgetLimit: float = Field(gt=0, description="Maximum budget allowed")
    location: str
    isOutdoor: bool = True
    inspirationImageUrl: Optional[str] = None

# 2. Individual Resource Item in Proposal
class ProposedItem(BaseModel):
    name: str
    category: str
    cost: float
    isSafeguard: bool = False
    reason: Optional[str] = None

# 3. LangGraph Shared State Schema (SE3090 Section 9 & 10 Compliance)
class AgentGraphState(TypedDict, total=False):
    workflow_id: str
    objective: EventObjectiveInput
    multi_step_plan: List[str]
    weather_assessment: Dict[str, Any]
    safeguard_item: Optional[ProposedItem]
    selected_venue: str
    cost_breakdown: List[ProposedItem]
    subtotal: float
    is_under_budget: bool
    budget_remaining: float
    validation_passed: bool
    requires_human_approval: bool
    approval_status: str
    audit_trace_logs: List[str]

# 4. Complete AI Output Contract (Public Response to ASP.NET Core)
class AgentWorkflowResult(BaseModel):
    workflowId: str
    eventId: str
    objectiveSummary: str
    multiStepPlan: List[str]
    weatherRiskAssessment: Dict[str, Any]
    selectedVenue: str
    costBreakdown: List[ProposedItem]
    subtotal: float
    isUnderBudget: bool
    budgetRemaining: float
    validationPassed: bool
    requiresHumanApproval: bool
    approvalStatus: str = "PendingManagerApproval"
    auditTraceLogs: List[str]