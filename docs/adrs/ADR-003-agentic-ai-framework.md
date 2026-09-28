# ADR 003: Multi-Agent Orchestration Framework via LangGraph

## Status
Accepted

## Context
SLIIT SE3090 Assignment 1 mandates an integrated full-stack and Agentic AI application. Specifically:
- **Section 9 & 9.1**: The Agentic AI subsystem must solve a multi-step domain objective; create a structured plan; delegate steps to at least **four distinct specialized agents** with allow-listed tools, deterministic validation, persisted shared state, and Human-in-the-Loop approval.
- **Section 10**: The AI service must operate strictly as an internal service invoked exclusively by the ASP.NET Core Web API, communicating state back to PostgreSQL and the React/Flutter client applications.
- **Section 11**: At least one meaningful third-party integration (e.g., OpenWeather API) with graceful failure and rate-limit handling.

## Options Considered
1. **Single-Prompt LLM / Simple Chatbot**: Fails Section 9 minimum acceptance criteria (explicitly prohibited in specification).
2. **LangChain SequentialChain**: Limited cyclic routing, rigid state transitions, lacks native graph-level state persistence.
3. **Microsoft Semantic Kernel / AutoGen**: Higher setup overhead and less direct compatibility with the lab stack used in SE3090.
4. **LangGraph (Python StateGraph)**: Recommended in course syllabus; provides native directed acyclic and cyclic state machines, typed shared state (`AgentGraphState`), granular node delegation, and Human-in-the-Loop approval holds.

## Decision
We implemented **LangGraph (Python)** using a compiled `StateGraph(AgentGraphState)` exposed via a high-performance FastAPI internal microservice on port 8000, consumed exclusively by the ASP.NET Core backend (`IAiWorkflowService`).

### Multi-Agent Graph Architecture & Group Member Ownership
Each of the 4 group members owns a distinct node with defined input/output contracts and allow-listed tools:

```text
[START: User Objective via ASP.NET Core]
                │
                ▼
┌────────────────────────────────────────────────────────┐
│ Node 1: planner_agent (Member 2 - Kasun)               │
│ • Decomposes high-level event goal into 4 execution    │
│   tasks and injects planning trace into State.         │
└──────────────────────────┬─────────────────────────────┘
                           │ (Edge)
                           ▼
┌────────────────────────────────────────────────────────┐
│ Node 2: weather_risk_agent (Member 3)                  │
│ • Tool 1: Live OpenWeatherMap 5-Day Forecast API       │
│ • Fallback: Historical Sri Lanka Seasonal Model        │
│ • Safeguard: Injects Marquee Tent if Rain >= 60%       │
└──────────────────────────┬─────────────────────────────┘
                           │ (Edge)
                           ▼
┌────────────────────────────────────────────────────────┐
│ Node 3: resource_optimizer_agent (Member 1)            │
│ • Tool 2: Sri Lankan Venue & Inventory DB Pricing Tool │
│ • Packages catering buffet, sound rig, and safeguards  │
└──────────────────────────┬─────────────────────────────┘
                           │ (Edge)
                           ▼
┌────────────────────────────────────────────────────────┐
│ Node 4: validation_safety_agent (Member 4)             │
│ • Deterministic Budget Guardrail (Subtotal <= Limit)   │
│ • Human-in-the-Loop Gate: Halts execution and sets     │
│   requiresHumanApproval=True for Manager review.       │
└──────────────────────────┬─────────────────────────────┘
                           │ (Edge)
                           ▼
                        [END]
```

## Consequences
- **Pros:**
  - 100% compliance with SE3090 Section 9, 9.1, and 10 requirements.
  - Clear, isolated individual ownership for all 4 students (12 marks individual criterion).
  - Strongly typed shared memory via `typing.TypedDict` (`AgentGraphState`).
  - Resilient dual-layer weather intelligence: real-time 5-day OpenWeather API coupled with an automatic fallback to the Sri Lanka Department of Meteorology seasonal monsoon model.
  - Zero breaking changes to ASP.NET Core controllers and database entities.
- **Cons:**
  - Requires hosting an internal Python runtime (`ai-service`) alongside the ASP.NET Core Web API.