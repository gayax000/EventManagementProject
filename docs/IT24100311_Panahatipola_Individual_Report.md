# Sri Lanka Institute of Information Technology
*(SLIIT)*

### SE3090 — SOFTWARE ENGINEERING FRAMEWORKS
**Year 3 Semester 1 – 2026**

**ASSIGNMENT 1**

---

## INDIVIDUAL REPORT
### COMPONENT 4: MANAGER GOVERNANCE & FINANCIAL SETTLEMENT

| Field | Details |
| :--- | :--- |
| **Student ID** | **IT24100311** |
| **Student Name** | **Panahatipola P.M.D.S.** |
| **Campus / Center name** | **SLIIT Kandy Uni** |
| **Specialization** | **Software Engineering** |
| **Batch No** | **1** |

---

## 1. MY CONTRIBUTION
I worked on **Component 4: Manager Governance & Financial Settlement** as the **Backend, Security & Financial Governance Lead**. My responsibility was to implement the manager approval workflows, financial settlement pipeline, bank deposit slip verification, tamper-evident digital QR entry pass issuance, and the Validation & Safety AI Agent. I engineered the Surgical Minimal Auto-Fit algorithm ($Cost \le Budget$) to guarantee that no AI-generated proposal violates client budget limits without manager review. I was fully responsible for this component across the ASP.NET Core API backend, PostgreSQL database, React manager portal, Flutter mobile client, and Python AI microservice.

**Main areas:**
* Financial Settlement & Payment Verification API (ASP.NET Core 8)
* Relational Financial Schema & Transactions (PostgreSQL 16 & EF Core 8)
* React Manager Review Portal, Auto-Fit Trigger & QR Verification Dashboard
* Flutter Payment Slip Uploader, Digital Signature & QR Entry Pass Display
* Validation & Safety AI Agent (LangGraph StateGraph)
* Surgical Minimal Auto-Fit Tool & Deterministic Guardrails
* Unit, Integration & Golden Case Testing

---

## 2. TECHNICAL WORK

### • ASP.NET Core Backend
I built the Financial Settlement and Verification subsystems using `PaymentsController.cs`, `VerifyController.cs`, and `PaymentVerificationService.cs`. The service implements JWT authentication, atomic database transactions (`IDbContextTransaction`), file upload security filters, and QR code verification. It exposes 5 core endpoints:

| Endpoint | Purpose |
| :--- | :--- |
| `POST /api/events/{id}/approve-proposal` | Manager HIL gate: executes Auto-Fit, approves proposal, and creates a formal Booking record |
| `POST /api/payments/upload-slip` | Handles multipart image upload for customer bank deposit slips (file size $\le 5$MB) |
| `POST /api/payments/verify` | Manager approval of deposit slip, updates payment status, and generates digital QR pass |
| `GET /api/verify/scan-pass` | Validates digital QR pass cryptographic signature at event venue entrance |
| `POST /api/events/{id}/override-price` | Allows managers to apply custom line-item discounts or price overrides prior to approval |

### • PostgreSQL / EF Core
I designed the financial settlement, invoicing, and entry pass relational tables using EF Core Code-First migrations with atomic transaction blocks:
* Designed tables: `Bookings`, `Payments`, `Invoices`, and `EntryPasses`.
* High-precision monetary columns enforce `numeric(12,2)` across `TotalAgreedAmount`, `Subtotal`, `DiscountAmount`, and `FinalTotal` to prevent rounding errors.
* Multi-entity operations—such as approving a proposal, creating a booking, and issuing an initial invoice—are executed inside atomic transaction blocks (`IDbContextTransaction`) guaranteeing ACID compliance.
* Created unique indexes `IX_Bookings_BookingReferenceCode` and `IX_EntryPasses_QrCodeData` for instant, collision-free lookups.

### • React Web Application
I developed the Manager Governance and Verification interfaces (`Dashboard.tsx` and `PaymentsPage.tsx`) using React 18 and Tailwind CSS:
* **Interactive Proposal Review Modal:** Displays itemized vendor costs, weather alerts, and budget progress bars.
* **Surgical Minimal Auto-Fit Trigger Button:** Allows managers to automatically downgrade oversized vendor packages to minimal compliant options with a single click.
* **Bank Deposit Slip Verification Card:** High-resolution image preview of uploaded deposit slips with one-click "Verify" and "Reject" actions.
* **Staff QR Entry Pass Scanner Console:** Web-based verification screen displaying guest pass clearance details upon check-in.

### • Flutter Application
I built the financial and entry pass features on the mobile client:
* **Deposit Slip Image Uploader:** Native camera and gallery integration via `image_picker` with client-side image compression and MIME type validation.
* **Digital Contract Signature Pad:** Integrated `signature` widget allowing customers to draw their signature on-screen before booking confirmation.
* **Dynamic QR Entry Pass Screen:** Renders unique, tamper-evident digital QR entry passes via `qr_flutter` once payment is verified.
* **Staff QR Scanner:** Integrated `mobile_scanner` to utilize the device camera for real-time ticket scanning at event entrances.

---

## 3. MY AI CONTRIBUTION
My primary AI deliverable was the **Validation & Safety Agent** (`agent_validation.py`), orchestrated as the final terminal node in the Python FastAPI LangGraph StateGraph engine.

* **Deterministic Budget Guardrail ($Cost \le Budget$):** Enforces a strict programmatic boundary where total estimated cost cannot exceed the user's budget ceiling under any circumstances.
* **Surgical Minimal Auto-Fit Tool:** When high-tier vendor selections cause a budget overrun, the tool calculates the exact deficit, identifies the least disruptive vendor package to downgrade (e.g. Luxury Photo -> Standard Photo), and swaps it to bring total cost strictly under budget without eliminating essential categories.
* **Human-in-the-Loop (HIL) Pause Gate:** Regardless of whether the proposal is within budget or adjusted via Auto-Fit, the agent marks the proposal with status `PendingManagerApproval`. High-impact financial commitments cannot be completed without explicit manager authorization.
* **LangGraph Integration:** As `validation_safety_node`, it receives the state from the Resource Optimizer Agent, validates budget safety, logs audit records, and returns the final `AgentWorkflowResult`.

| AI Tool | Purpose |
| :--- | :--- |
| `surgical_minimal_autofit` | Replaces oversized vendor items with minimal compliant packages to satisfy $Cost \le Budget$ |
| `validate_budget_guardrail` | Evaluates subtotal against target budget and sets boolean safety compliance flags |
| `generate_audit_trail` | Synthesizes all agent execution logs into a structured JSON audit trail for manager review |

---

## 4. INDIVIDUAL CONTRIBUTION EVIDENCE
All my individual deliverables were committed and merged on feature branches in the repository `gayax000/EventManagementProject`.

**Important Commits & Pull Requests:**

| Commit / PR | Description |
| :--- | :--- |
| `PR #9–10` | Built `PaymentsController.cs`, deposit slip uploader, and EF Core `Payments` table |
| `PR #11–12` | Implemented `VerifyController.cs` and digital QR pass generation with `qr_flutter` |
| `PR #23` | Engineered Surgical Minimal Auto-Fit algorithm and budget safety guardrail tool |
| `PR #24` | Integrated HIL Manager Approval Gate and transaction rollback handling |
| `Commit 014a2d8` | Implemented Real Vendor Switching and strict budget compliance in Auto-Fit button |

*(Screenshot Placeholder: Add a screenshot of your GitHub Pull Requests #9–12, #23–24 from github.com/gayax000/EventManagementProject)*

---

## 5. TESTING
I created automated test suites for financial calculations, payment slip uploads, QR verification, and budget guardrails:

* **xUnit Financial Tests (`PaymentVerificationTests.cs`):** 9 test cases verifying atomic transaction commits, invalid slip image rejection, duplicate reference code prevention, and QR signature checks – all passed.
* **AI Safety Tests (`test_validation_agent.py`):** 7 golden evaluation cases verifying $Cost \le Budget$ enforcement, Auto-Fit minimal package replacement, and HIL pause flags – all passed.
* **Cross-Platform QR Round-Trip Test:** Verified end-to-end QR pass generation in C# backend, display in Flutter mobile app, and scanning via mobile camera scanner.
* **Build Verification:** Backend `dotnet build` 0 errors; React web `npm run build` 0 TypeScript errors.

| Test File | What it covers | Tests | Status |
| :--- | :--- | :---: | :---: |
| `test_validation_agent.py` | Surgical Auto-Fit algorithm, budget guardrails, Pydantic audit logs | 7 | PASSED |
| `PaymentVerificationTests.cs` | Deposit slip verification, atomic transactions, QR pass creation | 6 | PASSED |
| `QrVerificationTests.cs` | QR signature integrity, one-time scan validation, expired pass checks | 4 | PASSED |
| **Total** | | **17** | **ALL PASSED** |

*(Screenshot Placeholder: Add a screenshot of xUnit and pytest test execution)*

---

## 6. CHALLENGES AND SOLUTIONS

1. **Unconstrained LLM Overruns on Tight Budgets:**
   * *Problem:* When user budget was low, LLM prompt engineering failed to stay within budget, frequently exceeding limits by 15–20% and claiming the budget was "unachievable".
   * *Solution:* Built the deterministic **Surgical Minimal Auto-Fit** algorithm in pure code rather than relying on LLM arithmetic. The algorithm programmatically scans vendor categories in reverse order of priority (Cake -> Transport -> Sound -> Photo -> Decor) and swaps items to the lowest tier until $Cost \le Budget$ is achieved.
2. **Race Conditions in Bank Slip Verification & Booking Generation:**
   * *Problem:* If a manager clicked "Verify" multiple times simultaneously, duplicate booking records and entry passes were created.
   * *Solution:* Wrapped proposal approval and payment verification inside an EF Core database transaction block (`IDbContextTransaction`) with a unique database constraint on `BookingReferenceCode`, ensuring idempotent, single-execution updates.
3. **Malicious File Uploads in Payment Slips:**
   * *Problem:* Customers could theoretically upload non-image files or oversized payloads disguised as deposit slips.
   * *Solution:* Implemented multi-layered validation in `PaymentsController`: checked magic byte file headers, restricted MIME types to `image/jpeg` and `image/png`, and enforced a strict 5 MB file size limit.

---

## 7. WHAT I LEARNED
This component gave me deep practical experience in **ACID database transactions in EF Core**, **secure file upload handling**, **cryptographic QR entry clearance**, and **deterministic safety engineering in Agentic AI**. I learned how critical Human-in-the-Loop governance is for high-stakes financial applications where AI cannot be granted autonomous authorization.

---

## 8. INDIVIDUAL AI USAGE LOG

| Date | AI Tool / Model | Task / Section | What I Changed & Verified |
| :--- | :--- | :--- | :--- |
| **05 Sep 2026** | Antigravity (Llama-3-70B) | Auto-Fit Guardrails | Replaced LLM math with deterministic tier-swapping algorithm |
| **12 Sep 2026** | GitHub Copilot (Claude 3.5) | C# Transaction Logic | Added `IDbContextTransaction` rollback handling in `PaymentsController` |
| **20 Sep 2026** | Antigravity (Gemini 3.7) | QR Code Verification | Implemented cryptographic hash signature verification for QR payloads |
| **25 Sep 2026** | Antigravity (Gemini 3.7) | HIL Approval Gate | Enforced `PendingManagerApproval` state lock on all generated plans |
| **28 Sep 2026** | GitHub Copilot (GPT-4o) | Flutter Signature Pad UI | Integrated `signature` widget controller with clean image export |

---

## 9. AI REFLECTION
I utilized Google Antigravity (Gemini 3.7 Flash) and GitHub Copilot for drafting C# transaction templates, creating React modal components, and generating QR code generation boilerplate. AI provided great speed when generating repetitive UI state handlers and unit test mocks.

However, AI was completely inadequate for financial safety rules and transaction boundaries. In early iterations, the AI model attempted to apply arbitrary "discounts" to make proposals fit budgets, effectively fabricating vendor pricing without business justification. It also omitted transaction rollback blocks in asynchronous database operations.

I rejected AI-generated financial shortcuts and implemented a deterministic Surgical Minimal Auto-Fit algorithm that only selects real, verified vendor packages. I also enforced explicit database transactions and Human-in-the-Loop review. This confirmed that while AI is useful for code generation, financial governance and safety guardrails must be governed by rigorous deterministic engineering.

---

## 10. DECLARATION
I confirm that this report and my Component 4 work are my own authentic effort. I have fully disclosed all AI tools used in the AI Usage Log and Reflection. I will not use any external AI assistant during the viva and demonstration, and I can independently explain, test, modify, and defend all code and architecture within my component.

* **Student ID:** **IT24100311**
* **Name:** **Panahatipola P.M.D.S.**
* **Signature:** _______________________
* **Date:** **30 September 2026**
