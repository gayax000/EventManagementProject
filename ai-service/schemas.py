from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional, Dict, Any
from typing_extensions import TypedDict
import uuid

# 1. User Event Request Input Contract
class EventObjectiveInput(BaseModel):
    model_config = ConfigDict(extra="ignore")

    eventId: str = Field(default_factory=lambda: str(uuid.uuid4()))
    title: str
    targetDate: str
    guestCount: int = Field(gt=0, description="Number of guests")
    budgetLimit: float = Field(gt=0, description="Maximum budget allowed")
    location: str
    isOutdoor: bool = True
    inspirationImageUrl: Optional[str] = None
    customPrompt: Optional[str] = Field(default=None, description="Natural language event vision prompt")
    selectedServices: Optional[List[str]] = Field(default_factory=list, description="Client selected vendor service categories")
    tableRefreshments: Optional[List[str]] = Field(default_factory=list, description="Client selected table refreshments & food add-ons")
    eventSession: Optional[str] = Field(default="DayLunch", description="Event session time slot (DayLunch, NightDinner, EveningHighTea)")
    cateringStyle: Optional[str] = Field(default="InternationalBuffet", description="Buffet style (InternationalBuffet, OutdoorBBQ, HighTeaCanape, SriLankanHeritage)")
    preferredLocation: Optional[str] = None
    additionalDetails: Optional[str] = None
    banquetHallName: Optional[str] = None
    hallRentalPrice: Optional[float] = 0.0
    perPlatePrice: Optional[float] = None

# 2. Individual Resource Item in Proposal
class ProposedItem(BaseModel):
    name: str
    category: str
    cost: float
    isSafeguard: bool = False
    reason: Optional[str] = None
    partner: Optional[str] = None
    vendorId: Optional[str] = None

# 3. LangGraph Shared State Schema (SE3090 Section 9 & 10 Compliance)
class AgentGraphState(TypedDict, total=False):
    workflow_id: str
    objective: EventObjectiveInput
    extracted_entities: Optional[Dict[str, Any]]
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
    extractedEntities: Optional[Dict[str, Any]] = None
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
    assignedVendors: Optional[List[Dict[str, Any]]] = Field(default_factory=list)