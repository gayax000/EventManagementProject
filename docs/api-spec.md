# Smart Event Management System - RESTful API Specification
**Module:** SE3090 - Software Engineering Frameworks (Assignment 1)  
**Backend:** ASP.NET Core Web API  
**Database:** PostgreSQL with Entity Framework Core  

---

## 1. Global API Standards
- **Base URL:** `https://api.eventcraft.local/api` (or `http://localhost:5000/api`)
- **Data Format:** JSON (`application/json`)
- **Authentication:** Bearer JWT Token (`Authorization: Bearer <token>`)
- **Common Status Codes:**
  - `200 OK`: Request succeeded.
  - `201 Created`: Resource successfully created.
  - `400 Bad Request`: Validation failure or business rule violation.
  - `401 Unauthorized`: Missing or invalid JWT token.
  - `403 Forbidden`: User role does not have permission.
  - `404 Not Found`: Resource not found.
  - `500 Internal Server Error`: Unhandled server exception.

---

## 2. Member 1: User Auth, Venue & Vendor Management

### 2.1 Auth & User Endpoints
* **`POST /api/auth/register`**
  - **Description:** Registers a new user account with hashed password. Default role: `Customer`.
  - **Request Body:** `{ "fullName": "John Doe", "email": "john@example.com", "password": "SecurePassword123!", "phoneNumber": "+94771234567" }`
  - **Response:** `201 Created` with User details (excluding password).
* **`POST /api/auth/login`**
  - **Description:** Authenticates credentials, issues a signed JWT token, and logs entry in `LoginLogs`.
  - **Request Body:** `{ "email": "john@example.com", "password": "SecurePassword123!" }`
  - **Response:** `200 OK` with `{ "token": "jwt-token-string", "role": "Customer", "userId": "uuid" }`.
* **`GET /api/users/profile`**
  - **Description:** Returns the authenticated user's profile details.
  - **Security:** `Authorize(Roles = "Customer, Manager, Admin, Vendor")`.

### 2.2 Venue Endpoints
* **`GET /api/venues`**
  - **Description:** Retrieves paginated list of venues with search & filtering (by capacity, indoor/outdoor, budget).
  - **Query Params:** `?search=Nuwara&minCapacity=100&isOutdoor=true&page=1&pageSize=10`
  - **Response:** `200 OK` with paginated venue array.
* **`POST /api/venues`**
  - **Description:** Creates a new venue entry.
  - **Security:** `Authorize(Roles = "Manager, Admin")`.
  - **Request Body:** `{ "name": "Grand Palm Garden", "locationAddress": "Nuwara Eliya", "maxCapacity": 300, "baseRentalPrice": 250000.00, "isOutdoor": true }`

### 2.3 Vendor Endpoints *(Business-Specific Operation)*
* **`POST /api/vendors/register`**
  - **Description:** Allows an organizer or supplier to register as a service vendor.
* **`PUT /api/vendors/{id}/verify`**
  - **Description:** **[Business-Specific]** Admin reviews credentials and updates vendor status to `Verified` or `Rejected` with audit notes.
  - **Security:** `Authorize(Roles = "Admin")`.
  - **Request Body:** `{ "status": "Verified", "adminRemarks": "Business registration documents verified." }`

---

## 3. Member 2: Event Request & Booking Core (Kasun)

### 3.1 Event Request Endpoints
* **`POST /api/events`**
  - **Description:** Creates a new event request with target dates, budget, and guest count. Status set to `UnderReview`.
  - **Security:** `Authorize(Roles = "Customer")`.
  - **Request Body:** `{ "title": "Annual Gala Dinner", "targetDate": "2026-11-15", "guestCount": 120, "budgetLimit": 1000000.00, "venueId": "uuid-venue", "inspirationImageUrl": "https://..." }`
  - **Response:** `201 Created` with created Event entity.
* **`GET /api/events/my-events`**
  - **Description:** Lists all event requests submitted by the logged-in customer with their current statuses.
  - **Security:** `Authorize(Roles = "Customer")`.
* **`DELETE /api/events/{id}/cancel`**
  - **Description:** Soft-cancels an event request if it has not yet reached confirmed booking stage.

### 3.2 Booking & Contract Endpoints *(Business-Specific Operation)*
* **`POST /api/bookings/{id}/sign-contract`**
  - **Description:** **[Business-Specific]** Customer signs the approved proposal digitally. Transitions booking status to `Confirmed & Signed` and triggers QR Pass generation.
  - **Security:** `Authorize(Roles = "Customer")`.
  - **Request Body:** `{ "digitalSignatureSvgOrUrl": "data:image/svg+xml;base64,...", "agreedTotalAmount": 880000.00 }`
  - **Response:** `200 OK` with Booking confirmation and QR Entry Pass reference.
* **`GET /api/bookings/{id}/entry-pass`**
  - **Description:** Retrieves the generated QR Code entry pass and PDF pass metadata.

### 3.3 Device Operation Endpoint (Mobile Feature)
* **`GET /api/entry-passes/{qrCodeData}/scan`**
  - **Description:** **[Device Feature: QR Scanner]** Event gate staff scan customer QR code via Flutter mobile camera to verify entrance validity.
  - **Security:** `Authorize(Roles = "Manager, Staff")`.
  - **Response:** `200 OK` `{ "isValid": true, "eventName": "Annual Gala Dinner", "customerName": "John Doe", "scannedAt": "timestamp" }`.

---

## 4. Member 3: Resource Allocation & Agentic AI Orchestration

### 4.1 Resource & Inventory Endpoints
* **`GET /api/resources`**
  - **Description:** Lists available resources (Catering menus, Sound/Light rigs, Marquee tents) with prices and stock levels.
* **`POST /api/resources`**
  - **Description:** Creates a new inventory item or service package.
  - **Security:** `Authorize(Roles = "Manager, Vendor")`.

### 4.2 Agentic AI Workflow Endpoints *(Business-Specific Operation)*
* **`POST /api/ai/workflow/initiate`**
  - **Description:** **[Business-Specific]** Triggers internal LangGraph multi-agent workflow. Evaluates weather risks via Weather API, optimizes catering/AV resources to fit user budget, and persists proposal in `AI_Workflow_States`.
  - **Request Body:** `{ "eventId": "uuid-event" }`
  - **Response:** `202 Accepted` `{ "workflowId": "uuid-workflow", "status": "PendingManagerApproval", "estimatedCost": 900000.00 }`.
* **`GET /api/ai/workflow/{workflowId}/status`**
  - **Description:** Fetches complete agent execution trail, weather assessment data, proposed breakdown, and validation logs.
* **`POST /api/ai/workflow/{workflowId}/approve`**
  - **Description:** **[Human-in-the-Loop]** Manager reviews AI proposal on React dashboard, optionally adds a custom discount, and approves it.
  - **Security:** `Authorize(Roles = "Manager")`.
  - **Request Body:** `{ "action": "Approve", "specialDiscount": 20000.00, "managerNotes": "Approved with loyalty discount." }`
* **`POST /api/ai/workflow/{workflowId}/revise`**
  - **Description:** Re-runs AI optimization based on customer revision feedback (e.g., "Change dinner buffet to option A").

---

## 5. Member 4: Payments, Invoices & Predictive Analytics

### 5.1 Payment Endpoints
* **`POST /api/payments/upload-slip`**
  - **Description:** Uploads customer bank transfer slip image/PDF to cloud storage and creates a `PendingVerification` payment record.
  - **Security:** `Authorize(Roles = "Customer")`.
  - **Content-Type:** `multipart/form-data`
  - **Payload:** `bookingId`, `amountPaid`, `slipFile` (image/pdf).
* **`PUT /api/payments/{id}/verify`**
  - **Description:** **[Business-Specific]** Admin reviews slip on React dashboard and approves/rejects payment. On approval, generates official PDF Invoice.
  - **Security:** `Authorize(Roles = "Admin, Manager")`.
  - **Request Body:** `{ "status": "Approved", "rejectReason": null }`

### 5.2 Invoice & Document Generation Endpoints
* **`GET /api/invoices/{bookingId}/download`**
  - **Description:** Streams official PDF invoice with breakdown and payment receipt.
  - **Response:** `application/pdf` binary stream.

### 5.3 Business Intelligence & Analytics Endpoints *(Business-Specific Operation)*
* **`GET /api/analytics/revenue-forecast`**
  - **Description:** **[Business-Specific]** AI Analytics Agent analyzes historical events, payments, and seasonality to predict future revenue and peak event dates.
  - **Security:** `Authorize(Roles = "Admin, Manager")`.
  - **Response:** `200 OK` `{ "projectedMonthlyRevenue": [...], "peakBookingMonths": ["November", "December"], "recommendedResourceStocking": [...] }`.
* **`GET /api/analytics/reports/export`**
  - **Description:** Exports historical financial and event audit reports as CSV/Excel.