# ADR 003: Multi-Agent Orchestration Framework

## Status
Accepted

## Context
The assignment mandates at least 4 distinct agents (Planner, Risk/Weather Analyzer, Budget/Resource Optimizer, Safety/Validator) with allow-listed tools, persisted shared state, and Human-in-the-Loop approval.

## Decision
We chose **LangGraph (Python)** running as an internal microservice, invoked exclusively by the ASP.NET Core Web API.

## Consequences
- **Pros:** Native cyclic graph support, deterministic state persistence, built-in Human-in-the-Loop interrupt/resume primitives.
- **Cons:** Requires hosting a secondary internal Python runtime alongside ASP.NET Core.