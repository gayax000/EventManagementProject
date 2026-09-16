from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any

# 1. User Event Request Input
class EventObjectiveInput(BaseModel):
    eventId: str
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

# 3. Complete AI Output Contract
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