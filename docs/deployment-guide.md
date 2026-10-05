# 🚀 EventCraft AI - Canonical Deployment & Evaluation Guide

This document represents the single source of truth for production deployment URLs, environment variables, system endpoints, and test credentials.

---

## 🌐 Production URLs & System Endpoints

| Component | Platform | URL / Endpoint | Status |
| :--- | :--- | :--- | :---: |
| **ASP.NET Core Web API** | Railway Cloud | `https://eventmanagementproject-production-94fe.up.railway.app/api` | 🟢 Live |
| **Interactive Swagger API Spec** | Railway Cloud | `https://eventmanagementproject-production-94fe.up.railway.app/swagger` | 🟢 Live |
| **System Health Check** | Railway Cloud | `https://eventmanagementproject-production-94fe.up.railway.app/health` | 🟢 Live |
| **PostgreSQL Database** | Neon Cloud | `neondb` (PostgreSQL 16) | 🟢 Live |
| **React 19 Web Manager Portal** | Vercel / Railway | `https://eventmanagementproject-web.vercel.app` / Localhost:5173 | 🟢 Live |
| **Flutter Mobile Application** | Android APK | Release APK Artifact (`app-release.apk`) | 🟢 Built |

---

## 🔐 Evaluation Test Credentials

| Role | Email | Password | Access Rights |
| :--- | :--- | :--- | :--- |
| **Operations Manager** | `manager@eventcraft.lk` | `Manager@2026` | Full Manager Portal access, AI Proposal Approval, Payment Slip Verification, Vendor Verification |
| **Client / Customer** | `sahan@gmail.com` | `Customer@2026` | Event Creation, Inquiry Builder, Proposal Review, Payment Slip Upload, QR Entry Pass |
| **System Catalog Vendor** | `catalog-system@eventcraft.lk` | `SystemCatalog@2026` | Service Catalog & Work Order View |

---

## ⚙️ Production Environment Variables

### ASP.NET Core Web API (`backend/EventManagement.Api`)
- `ConnectionStrings__DefaultConnection`: Neon Cloud PostgreSQL connection string
- `JwtSettings__SecretKey`: 64-byte random HMAC-SHA256 secret key
- `JwtSettings__Issuer`: `EventCraft.Api`
- `JwtSettings__Audience`: `EventCraft.Client`
- `PORT`: `8080`

### Python Agentic AI Subsystem (`ai-service/`)
- `OPENWEATHER_API_KEY`: OpenWeatherMap 5-Day Forecast API Key (`0a87ba3892616d06236da5470bca8bea`)
- `PORT`: `8000`

---

## 🧪 Verification Commands
```powershell
# 1. Build and Run Backend Unit & Integration Tests (21 Passed)
dotnet test backend/EventManagement.Tests/EventManagement.Tests.csproj

# 2. Run Python Agentic AI Evaluation Tests (9 Passed)
cd ai-service
python -m unittest test_agent_evaluation.py

# 3. Execute k6 Load Test Benchmark
k6 run performance/k6_venues_test.js
```
