# SE3090 Assignment 1 - Agentic AI Compliance & Acceptance Matrix

| Rubric Acceptance Criterion | System Implementation | Code File Reference & Line Numbers | Status |
| :--- | :--- | :--- | :---: |
| **1. Domain Goal & Objective Input** | `EventObjectiveInput` Pydantic model encapsulating title, guests, budget, location, outdoor setting, target date, and custom prompt | [schemas.py](file:///d:/EventManagement/ai-service/schemas.py#L4-L14) | ✅ Pass |
| **2. Multi-Step Execution Plan** | Dynamic task decomposition based on extracted NLP category and theme preferences | [agent_planner.py](file:///d:/EventManagement/ai-service/agent_planner.py#L33-L40) | ✅ Pass |
| **3. Four Distinct Specialized Agents** | Member 2 (Planner), Member 3 (Weather Risk), Member 1 (Resource Optimizer), Member 4 (Validation Safety) | [main.py](file:///d:/EventManagement/ai-service/main.py#L31-L34) | ✅ Pass |
| **4. LangGraph Orchestration & State Machine** | Sequential `StateGraph(AgentGraphState)` compiled graph executing nodes in strict order | [main.py](file:///d:/EventManagement/ai-service/main.py#L86-L102) | ✅ Pass |
| **5. Controlled Allow-listed Tools** | `check_weather_forecast`, `query_venue_and_inventory`, `extract_event_entities_tool` | [tools.py](file:///d:/EventManagement/ai-service/tools.py#L151-L322) | ✅ Pass |
| **6. Deterministic Guardrails & Safety Gate** | ValidationSafetyAgent enforces `subtotal <= budgetLimit` and integrity checks | [agent_validation_safety.py](file:///d:/EventManagement/ai-service/agent_validation_safety.py#L12-L37) | ✅ Pass |
| **7. Human-in-the-Loop (HITL) Interceptor** | Pauses workflow at `PendingManagerApproval` state until authorized Manager approves/revises | [AiWorkflowController.cs](file:///d:/EventManagement/backend/EventManagement.Api/Controllers/AiWorkflowController.cs#L68-L82) | ✅ Pass |
| **8. State Persistence in PostgreSQL** | Stores workflow ID, event ID, estimated cost, generated plan JSON, weather assessment JSON, and approval status in `AIWorkflowStates` table | [AppDbContext.cs](file:///d:/EventManagement/backend/EventManagement.Infrastructure/Data/AppDbContext.cs) | ✅ Pass |
| **9. Graceful Weather API Safe-Failure** | Live OpenWeatherMap API with 5.0s timeout and automatic fallback to Sri Lanka Climatological Model | [tools.py](file:///d:/EventManagement/ai-service/tools.py#L170-L238) | ✅ Pass |
| **10. Prompt Injection Resistance** | Security sanitization check identifying SQL/script/instruction override attempts | [tools.py](file:///d:/EventManagement/ai-service/tools.py#L312-L320) | ✅ Pass |

## Verification Execution
- **Python Unit Test Suite:** Run `python -m unittest test_agent_evaluation.py` (7/7 Passed)
- **.NET Integration Test Suite:** Run `dotnet test backend/EventManagement.Tests/EventManagement.Tests.csproj` (21/21 Passed)
