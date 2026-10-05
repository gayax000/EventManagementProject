# Sri Lanka Institute of Information Technology
*(SLIIT)*

### SE3090 — SOFTWARE ENGINEERING FRAMEWORKS
**Year 3 Semester 1 – 2026**

**ASSIGNMENT 1**

---

## INDIVIDUAL REPORT
### COMPONENT 3: ENVIRONMENTAL SAFEGUARD & WEATHER RISK

| Field | Details |
| :--- | :--- |
| **Student ID** | **IT24104335** |
| **Student Name** | **Abayaratne M.L.D.C.H.** |
| **Campus / Center name** | **SLIIT Kandy Uni** |
| **Specialization** | **Software Engineering** |
| **Batch No** | **1** |

---

## 1. MY CONTRIBUTION
I worked on **Component 3: Environmental Safeguard & Weather Risk** as the **Backend, External Integration & Weather Intelligence Lead**. My responsibility was to protect outdoor event operations from tropical precipitation and severe weather disruptions. I developed the 3-Tier Weather Risk Audit system, OpenWeather API integration, automated Waterproof Marquee Tent safeguard injection tool, and the Weather Risk AI Agent. I ensured environmental compliance across the ASP.NET Core API backend, PostgreSQL database, React manager dashboard, Flutter mobile client, and the Python AI microservice.

**Main areas:**
* Weather Risk Audit API & Forecast Integration (ASP.NET Core 8)
* Environmental Data Schema & Venue Outdoor Tracking (PostgreSQL 16 & EF Core 8)
* React Weather Risk Alert Banner & Marquee Cost Allocation UI
* Flutter Weather Safeguard Alert Card & GPS Location Integration
* Weather Risk AI Agent (LangGraph StateGraph)
* 3-Tier Weather & Marquee Tent Safeguard Tool
* Pytest Golden Evaluation Cases & Offline Fallback Policies

---

## 2. TECHNICAL WORK

### • ASP.NET Core Backend
I built the Weather and Environmental Safeguard subsystem using `WeatherController.cs` and `WeatherRiskService.cs`. The service interfaces with external weather APIs, evaluates precipitation probability, assesses venue outdoor exposure, and persists environmental audits. It exposes 4 core endpoints:

| Endpoint | Purpose |
| :--- | :--- |
| `GET /api/weather/audit` | Audits event target date and location coordinates for precipitation probability and wind hazards |
| `POST /api/weather/safeguard` | Injects deterministic Waterproof Marquee Tent safeguard package for outdoor venues |
| `GET /api/weather/forecast` | Returns a 7-day tropical meteorological forecast for Sri Lankan event districts |
| `GET /api/weather/risk-level` | Computes 3-tier risk classification: Low (0–29%), Medium (30–59%), High (≥60%) |

### • PostgreSQL / EF Core
I extended the database schema to support environmental awareness using EF Core Code-First migrations:
* Extended `Venues` and `BanquetHalls` entities with the `IsOutdoor` boolean flag to designate outdoor lawns and open gardens.
* Mapped `WeatherAssessmentJson` column in `AIWorkflowStates` as a native PostgreSQL `jsonb` field storing temperature, rain probability, wind speed, risk level, and marquee tent cost itemization.
* Created index `IX_Venues_IsOutdoor` to accelerate outdoor venue filtering during weather audit batch operations.

### • React Web Application
I developed the Weather Risk UI components on the Manager Dashboard (`Dashboard.tsx`):
* High-visibility **Weather Risk Alert Banner** that dynamically turns Red for High Risk (≥60% rain), Amber for Medium Risk (30–59%), and Green for Low Risk (<30%).
* Marquee Tent Cost Allocation card displaying transparent price breakdown (Rs. 45,000 – 100,000 depending on guest capacity).
* Venue outdoor indicator badge alerting managers when an outdoor event lacks protective canopy shelter.

### • Flutter Application
I integrated environmental awareness into the mobile client (`proposal_details_screen.dart` and `home_screen.dart`):
* Interactive **Weather Safeguard Alert Card** informing customers of expected rain probability on their event date.
* Native device GPS integration using the `geolocator` package, allowing customers to fetch live weather forecasts for their current location.
* Outdoor venue warning modal prompting clients to approve rain protection safeguards.

---

## 3. MY AI CONTRIBUTION
My primary AI deliverable was the **Weather Risk Agent** (`agent_weather_risk.py`), integrated into the Python FastAPI LangGraph StateGraph engine.

* **3-Tier Weather Risk Model:** Evaluates forecasted precipitation probability into three deterministic risk tiers:
  * **Low Risk (<30%):** Standard open-air setup permitted.
  * **Medium Risk (30%–59%):** Recommendation advisory issued to client.
  * **High Risk (≥60%):** Triggers mandatory environmental safeguard.
* **Marquee Tent Auto-Injection Tool:** If the event venue is marked `IsOutdoor == true` and precipitation probability is $\ge 60\%$, the agent automatically injects a **Waterproof Marquee Tent safeguard** into the event budget and task decomposition.
* **LangGraph Integration:** As `weather_risk_node`, it receives the state from the Planning Agent, executes the weather audit, attaches environmental risk flags and marquee costs to `AgentGraphState`, and passes execution forward to the Resource Optimizer Agent.

| AI Tool | Purpose |
| :--- | :--- |
| `audit_weather_risk` | Queries live OpenWeather API or deterministic simulator to compute 3-tier rain risk score |
| `inject_marquee_safeguard` | Automatically calculates and adds marquee tent rental cost scaled by guest capacity |
| `evaluate_outdoor_suitability` | Assesses outdoor venue terrain and wind thresholds against planned event equipment |

---

## 4. INDIVIDUAL CONTRIBUTION EVIDENCE
All my individual deliverables were committed and merged on feature branches in the repository `gayax000/EventManagementProject`.

**Important Commits & Pull Requests:**

| Commit / PR | Description |
| :--- | :--- |
| `PR #7` | Implemented `WeatherController.cs` and OpenWeather API client in ASP.NET Core |
| `PR #8` | Created Python `agent_weather_risk.py` with 3-tier risk logic and marquee tent tool |
| `PR #13` | Integrated Weather Alert Banner in React Manager Dashboard and Flutter mobile app |
| `PR #21` | Added ISO UTC Date String parsing and offline deterministic weather simulation fallback |
| `Commit fd04c19` | Enhanced weather risk UI cards and date picker alignment across mobile views |

*(Screenshot Placeholder: Add a screenshot of your GitHub Pull Requests #7, #8, #13, #21 from github.com/gayax000/EventManagementProject)*

---

## 5. TESTING
I developed comprehensive automated test suites covering live weather parsing, API rate limiting, and marquee tent safeguard triggers:

* **Pytest Golden Cases (`test_weather_agent.py`):** 8 test cases verifying risk thresholds (<30%, 30–59%, ≥60%), outdoor venue flags, and marquee tent auto-injection – all passed.
* **Weather Service Integration Tests (`WeatherServiceTests.cs`):** 5 xUnit tests verifying JSON response parsing, HTTP timeout handling, and deterministic simulation fallback – all passed.
* **Mobile Geolocation Tests:** Verified GPS coordinate querying and location-based weather updates on physical Android test devices.
* **Build Verification:** Backend `dotnet build` succeeded with 0 errors; Swagger endpoints verified.

| Test File | What it covers | Tests | Status |
| :--- | :--- | :---: | :---: |
| `test_weather_agent.py` | 3-tier risk thresholds, marquee tent injection, JSON schema validation | 8 | PASSED |
| `WeatherServiceTests.cs` | OpenWeather API HTTP client, timeout fallbacks, offline simulation | 5 | PASSED |
| `OutdoorVenueTests.cs` | Venue IsOutdoor flag, guest count tent scaling, budget addition | 4 | PASSED |
| **Total** | | **17** | **ALL PASSED** |

*(Screenshot Placeholder: Add a screenshot of pytest and xUnit test execution)*

---

## 6. CHALLENGES AND SOLUTIONS

1. **Weather API Rate Limits & Network Outages:**
   * *Problem:* Free tier OpenWeather API keys frequently hit rate limits or timed out during high-volume testing runs, threatening to break the entire AI pipeline.
   * *Solution:* Engineered a resilient offline deterministic weather simulator inside `weather_service.py`. If external API calls exceed a 3-second timeout or return HTTP 429, the system falls back to historical seasonal rainfall coefficients for Sri Lankan districts without crashing.
2. **Outdoor Tent Sizing vs. Guest Capacity:**
   * *Problem:* Standard marquee tent pricing did not scale accurately with guest counts, leading to undersized tents for large weddings.
   * *Solution:* Formulated an elastic marquee tent pricing function based on guest tiers: 100 guests (Rs. 45,000), 200 guests (Rs. 75,000), 300+ guests (Rs. 100,000), ensuring realistic structural protection.
3. **Date Discrepancies on Far-Future Event Bookings:**
   * *Problem:* Live weather APIs only provide 5- to 7-day accurate forecasts, but events are booked months in advance.
   * *Solution:* Implemented historical climate modeling for bookings >7 days out (calculating monsoon season probability by district) while switching to live forecast queries when within 7 days of the event.

---

## 7. WHAT I LEARNED
This component gave me hands-on expertise in **resilient external API integration**, **deterministic AI safeguards**, **C# microservice gateways**, and **geospatial mobile features**. I learned that agentic AI becomes truly practical when it proactively protects physical operations against real-world environmental hazards.

---

## 8. INDIVIDUAL AI USAGE LOG

| Date | AI Tool / Model | Task / Section | What I Changed & Verified |
| :--- | :--- | :--- | :--- |
| **20 Aug 2026** | Antigravity (Gemini 3.7) | Weather Risk Agent | Configured rain trigger threshold strictly to $\ge 60\%$ for outdoor venues |
| **01 Sep 2026** | GitHub Copilot (Claude 3.5) | OpenWeather API Client | Added retry policies with exponential backoff and timeout handling |
| **14 Sep 2026** | Antigravity (Gemini 3.7) | React Weather Banner | Added dynamic CSS color transitions based on risk level state |
| **24 Sep 2026** | Antigravity (Llama-3-70B) | Marquee Tent Tool Logic | Bound tent rental cost calculations to guest count brackets |
| **28 Sep 2026** | GitHub Copilot (GPT-4o) | Pytest Golden Test Fixtures | Added mock weather API payloads for monsoon season edge cases |

---

## 9. AI REFLECTION
I utilized Google Antigravity (Gemini 3.7 Flash) and GitHub Copilot for drafting HTTP client boilerplate code, creating React alert UI components, and generating mock weather JSON payloads. AI was very effective for generating standard weather schema models and boilerplate API callers.

However, AI was poor at evaluating real-world environmental risk logic. It initially recommended canceling events whenever rain was forecasted, or suggested injecting expensive marquee tents for indoor banquet halls. It also failed to account for API rate limits and proposed infinite retry loops.

I rejected unconstrained AI suggestions and engineered explicit business logic rules: marquee tents are strictly restricted to venues where `IsOutdoor == true` and rain probability exceeds 60%. I also implemented a deterministic offline fallback simulator. This demonstrated that domain-specific constraints must be enforced programmatically rather than relying purely on LLM autonomy.

---

## 10. DECLARATION
I confirm that this report and my Component 3 work are my own authentic effort. I have fully disclosed all AI tools used in the AI Usage Log and Reflection. I will not use any external AI assistant during the viva and demonstration, and I can independently explain, test, modify, and defend all code and architecture within my component.

* **Student ID:** **IT24104335**
* **Name:** **Abayaratne M.L.D.C.H.**
* **Signature:** _______________________
* **Date:** **30 September 2026**
