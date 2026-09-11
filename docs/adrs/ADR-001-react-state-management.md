# ADR 001: State Management in React Web Application

## Status
Accepted

## Context
The React application serves administrative, staff, and manager roles. It requires handling complex forms, real-time approval status updates, AI execution logs, and role-based route authentication.

## Decision
We chose **Zustand** (or Redux Toolkit) for global state management combined with React Context for local auth tokens.

## Consequences
- **Pros:** Minimal boilerplate compared to classic Redux, fast performance, easy testing and debugging.
- **Cons:** Requires consistent conventions across all 4 team members.