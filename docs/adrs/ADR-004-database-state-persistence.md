# ADR 004: Agent Workflow State Persistence in PostgreSQL

## Status
Accepted

## Context
The system needs to persist complex multi-agent execution plans, tool call logs, and validation results without losing historical audit trails.

## Decision
We chose PostgreSQL with Entity Framework Core, storing structured workflow states using PostgreSQL's native **`jsonb`** columns within the `AI_Workflow_States` table.

## Consequences
- **Pros:** Schema flexibility for complex agent outputs while maintaining strong relational constraints for business data.
- **Cons:** Requires JSON validation logic before persisting data.