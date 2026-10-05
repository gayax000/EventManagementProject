# ADR 001: State Management in React Web Application

## Status
Accepted

## Context
The React application serves administrative, staff, and manager roles. It requires handling complex forms, real-time approval status updates, AI execution logs, and role-based route authentication.

## Decision
We chose **React Hooks (`useState`, `useEffect`) combined with Reusable Axios API Service Modules** for modular component state management and authentication token storage in `localStorage`.

## Consequences
- **Pros:** Zero unnecessary boilerplate, predictable component rendering, native React performance, lightweight bundle size, and easy API mocking for testing.
- **Cons:** Heavy global cross-component state requires explicit prop lifting or React Context when scaling across deeply nested trees.
- **Alternatives Considered:** Zustand and Redux Toolkit were evaluated, but deemed overly complex for the decoupled Manager and Customer dashboard view requirements.