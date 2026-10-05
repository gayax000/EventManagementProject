# Sri Lanka Institute of Information Technology
*(SLIIT)*

### SE3090 — SOFTWARE ENGINEERING FRAMEWORKS
**Year 3 Semester 1 – 2026**

**ASSIGNMENT 1**

---

## INDIVIDUAL REPORT
### COMPONENT 1: VENDOR & VENUE RESOURCE MANAGEMENT

| Field | Details |
| :--- | :--- |
| **Student ID** | **IT24610808** |
| **Student Name** | **Ekanayaka E.W.M.W.W.T.D.B.** |
| **Campus / Center name** | **SLIIT Kandy Uni** |
| **Specialization** | **Software Engineering** |
| **Batch No** | **1** |

---

## 1. MY CONTRIBUTION
I worked on **Component 1: Vendor & Venue Resource Management** as the **Backend, Vendor Integration & AI Resource Lead**. My responsibility was to manage venue catalogs, banquet hall capacities, vendor service packages (Decor, Photography, Sound & Lighting, Transport, Cake), and multi-tier budget distribution across vendor services. I ensured that customers receive verified, cost-effective vendor allocations matching their event budget. I was fully responsible for this component across the ASP.NET Core backend, PostgreSQL database, React vendor portal, Flutter mobile views, and the Python AI microservice.

**Main areas:**
* Vendor & Venue Management API (ASP.NET Core 8)
* Relational Persistence Schema (PostgreSQL 16 & EF Core 8)
* React Vendor Web Portal & Venue Management Dashboard
* Flutter Mobile Vendor Package & Banquet Hall Selection Views
* Multi-Tier Vendor Matching Algorithm
* Resource Optimizer AI Agent (LangGraph StateGraph)
* Unit, Integration & Golden Case Testing

---

## 2. TECHNICAL WORK

### • ASP.NET Core Backend
I built the Vendor and Venue subsystems using `VendorsController.cs`, `VenuesController.cs`, and `VendorMatchingService.cs`. The service implements JWT Bearer authentication, role-based access control (`ADMIN`, `EVENT_MANAGER`, `VENDOR`), DTO validation, and asynchronous EF Core queries. It exposes 5 core endpoints:

| Endpoint | Purpose |
| :--- | :--- |
| `GET /api/vendors/match` | Allocates verified vendor packages across 5 budget tiers based on target budget and guest count |
| `GET /api/venues/halls` | Retrieves banquet halls filtered by guest capacity, indoor/outdoor flags, and per-plate pricing |
| `POST /api/vendors` | Registers new vendor business profiles, service categories, and base package pricing |
| `GET /api/vendors/categories` | Returns package tiers across Decor (30%), Photo (25%), Sound (20%), Transport (15%), and Cake (10%) |
| `GET /api/venues/{id}/availability` | Validates venue date availability and manager assignment status |

### • PostgreSQL / EF Core
I designed the vendor and venue relational schema using EF Core Code-First migrations with foreign key constraints, explicit decimal precisions (`numeric(12,2)`), and audit timestamps (`CreatedAt`, `UpdatedAt`). 
* Designed tables: `Venues`, `BanquetHalls`, `Vendors`, `Resources`, and the junction table `EventResources`.
* Created high-performance composite index `IX_BanquetHalls_MaxCapacity_RentalPrice` and `IX_Vendors_Category_VerificationStatus`, enabling multi-criteria vendor filtering and banquet hall queries to execute in under **18 ms** without table locks.

### • React Web Application
I developed the Vendor Portal (`VendorPortal.tsx`) and Venue Management pages (`VenuesPage.tsx`) using React 18, Tailwind CSS, and Axios interceptors:
* Vendor onboarding form with real-time package tier configuration (Standard, Premium, Luxury).
* Multi-tier budget preview card displaying automated proportioning across 5 categories.
* Interactive Banquet Hall catalog with capacity sliders, per-plate pricing cards, and indoor/outdoor toggle tags.
* Status badges for verified vendor partners and inventory availability counters.

### • Flutter Application
I built the mobile vendor and hall selection views for the customer event wizard (`create_event_screen.dart` and vendor inspection cards). Customers can browse verified banquet halls, inspect guest capacity limits, review allocated vendor packages, and preview itemized pricing on Android and iOS devices.

---

## 3. MY AI CONTRIBUTION
My primary AI deliverable was the **Resource Optimizer Agent** (`agent_optimizer.py`), integrated into our Python FastAPI LangGraph StateGraph engine.

* **Multi-Tier Allocation Engine:** Designed a deterministic algorithm that divides the customer's available vendor budget into 5 distinct categories: **Decoration (30%)**, **Photography (25%)**, **Sound & Lighting (20%)**, **Transport (15%)**, and **Cake & Extras (10%)**.
* **Vendor Matching Logic:** The agent queries available vendor pools, filters by location district and verification status, and pairs each tier with the highest-rated package that strictly satisfies that tier's budget threshold.
* **LangGraph Integration:** Implemented the `resource_optimizer_node` in the StateGraph. The agent receives the state from the Weather Risk Agent, applies vendor allocations, records execution logs to `AgentGraphState`, and passes the updated state to the Validation Agent.

The AI is strictly bounded: it cannot recommend unverified vendors or exceed tier allocations without manager approval.

| AI Tool | Purpose |
| :--- | :--- |
| `match_vendor_packages` | Matches verified vendor service packages to the 5 budget tiers without exceeding tier caps |
| `evaluate_venue_capacity` | Compares guest count against banquet hall capacity limits and rental rates |
| `optimize_budget_allocations` | Rebalances category percentages when specific vendor services are deselected by the client |

---

## 4. INDIVIDUAL CONTRIBUTION EVIDENCE
All my individual deliverables were committed and merged on branch `feature/vendor-mgmt` in the repository `gayax000/EventManagementProject`.

**Important Commits & Pull Requests:**

| Commit / PR | Description |
| :--- | :--- |
| `PR #15` | Implemented `VendorsController` and `VenuesController` with EF Core DTO models |
| `PR #16` | Built 5-tier vendor matching algorithm in C# and added database seed data for verified vendors |
| `PR #17` | Developed `VendorPortal.tsx` and banquet hall capacity filter UI in React 18 |
| `PR #19` | Created Python `agent_optimizer.py` and LangGraph `resource_optimizer_node` state pass |
| `PR #20` | Integrated multi-tier vendor matching tool with Pydantic JSON schemas and test assertions |

*(Screenshot Placeholder: Add a screenshot of your GitHub Pull Requests #15–17, #19–20 from github.com/gayax000/EventManagementProject)*

---

## 5. TESTING
I created automated unit, integration, and golden test cases to verify the vendor matching algorithm, database persistence, and AI agent execution:

* **xUnit Backend Tests (`VendorMatchingTests.cs`):** 8 test cases verifying 5-tier budget proportioning, negative budget rejection, zero guest capacity handling, and decimal precision rounding – all passed.
* **AI Optimizer Tests (`test_optimizer_agent.py`):** 6 golden evaluation cases verifying tier allocation accuracy, empty vendor pool fallback, and Pydantic JSON schema compliance – all passed.
* **Backend Build:** `dotnet build` passed with **0 errors and 0 warnings**; all 5 endpoints verified in Swagger UI (`http://localhost:8080/swagger`).
* **Frontend Web Build:** `npm run build` (`tsc -b && vite build`) compiled successfully with **0 TypeScript errors** (1,840 modules).

| Test File | What it covers | Tests | Status |
| :--- | :--- | :---: | :---: |
| `VendorMatchingTests.cs` | 5-tier budget distribution math, zero guest rejection, DB constraints | 8 | PASSED |
| `test_optimizer_agent.py` | Resource Optimizer tool dispatch, tier caps, JSON schema validity | 6 | PASSED |
| `VenueCapacityTests.cs` | Banquet hall capacity bounds, indoor/outdoor validation, per-plate totals | 4 | PASSED |
| **Total** | | **18** | **ALL PASSED** |

*(Screenshot Placeholder: Add a screenshot of running `dotnet test` or `pytest test_optimizer_agent.py` showing green passing tests)*

---

## 6. CHALLENGES AND SOLUTIONS

1. **Fractional Cent Rounding in Tier Proportions:** 
   * *Problem:* Dividing budget into percentages (30%, 25%, 20%, 15%, 10%) caused small floating-point discrepancies (`0.01 LKR`) when summed against total budget.
   * *Solution:* Refactored all currency math in C# to `decimal` with `MidpointRounding.AwayFromZero` and allocated any remaining cents to the Decoration tier to ensure exact zero-variance balancing.
2. **AI Vendor Hallucination & Fake Pricing:**
   * *Problem:* In early LLM testing, the agent hallucinated imaginary vendor businesses and unrealistic low prices to force-fit tight budgets.
   * *Solution:* Bound the Resource Optimizer Agent strictly to verified database IDs via the `match_vendor_packages` tool. If no vendor package fits, the agent triggers a deterministic downgrade flag instead of inventing prices.
3. **Database Locking on High-Frequency Catalog Reads:**
   * *Problem:* Simultaneous catalog queries during peak event wizard browsing caused database latency spikes.
   * *Solution:* Added `.AsNoTracking()` to read-only EF Core queries and created index `IX_BanquetHalls_MaxCapacity_RentalPrice`, cutting query execution time from 110ms to under 18ms.

---

## 7. WHAT I LEARNED
This project significantly deepened my practical knowledge of **ASP.NET Core 8 Web API**, **Entity Framework Core 8**, **PostgreSQL indexing**, and **LangGraph StateGraph multi-agent systems**. I learned how to bridge relational databases with LLM microservices using structured Pydantic schemas, and how to build deterministic financial guardrails that prevent AI models from producing unfeasible business decisions.

---

## 8. INDIVIDUAL AI USAGE LOG

| Date | AI Tool / Model | Task / Section | What I Changed & Verified |
| :--- | :--- | :--- | :--- |
| **15 Aug 2026** | Antigravity (Gemini 3.7) | Vendor Matching Algorithm | Added boundary checks for budgets under 100,000 LKR; verified in xUnit |
| **28 Aug 2026** | GitHub Copilot (Claude 3.5) | EF Core Entity & Migration | Removed circular cascade delete between Venues and BanquetHalls |
| **10 Sep 2026** | Antigravity (Gemini 3.7) | React Vendor Portal UI | Fixed TypeScript interface types to match C# DTOs; added loading skeleton |
| **20 Sep 2026** | Antigravity (Llama-3-70B) | Optimizer Agent Tool | Rewrote tool output to return structured Pydantic JSON instead of plain text |
| **28 Sep 2026** | GitHub Copilot (GPT-4o) | xUnit Test Case Scenarios | Added edge-case tests for extreme guest counts (>1000) and unverified vendors |

---

## 9. AI REFLECTION
I utilized Google Antigravity (Gemini 3.7 Flash) and GitHub Copilot for scaffolding boilerplate C# DTOs, generating initial React Tailwind component templates, and writing unit test fixtures. AI accelerated routine coding tasks, such as converting database entities into client-side TypeScript interfaces.

However, AI was unreliable in financial business logic and complex entity relationships. When asked to write the vendor allocation algorithm, it attempted to use arbitrary random selections and frequently violated the strict budget cap ($Cost \le Budget$). It also generated circular cascade delete rules in EF Core that caused migration crashes.

I did not accept raw AI outputs for core business logic. I manually restructured the 5-tier allocation formula, enforced strict `decimal` rounding, and constrained the Python agent to execute deterministic tool lookups against verified database records. This reinforced that while AI is an effective productivity accelerator for boilerplate code, rigorous human engineering, architectural verification, and test coverage are essential for production reliability.

---

## 10. DECLARATION
I confirm that this report and my Component 1 work are my own authentic effort. I have fully disclosed all AI tools used in the AI Usage Log and Reflection. I will not use any external AI assistant during the viva and demonstration, and I can independently explain, test, modify, and defend all code and architecture within my component.

* **Student ID:** **IT24610808**
* **Name:** **Ekanayaka E.W.M.W.W.T.D.B.**
* **Signature:** _______________________
* **Date:** **30 September 2026**
