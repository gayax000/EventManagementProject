# ADR 002: State Management in Flutter Mobile Application

## Status
Accepted

## Context
The Flutter mobile application needs to manage customer authentication tokens, event booking requests, live status updates, and interactive AI chat revisions with predictable UI state.

## Decision
We chose **Provider Pattern & StatefulWidgets combined with HTTP Services** for Dart mobile UI state management and JWT token persistence in `SharedPreferences`.

## Consequences
- **Pros:** Native Flutter performance, compile-time safety, clean separation of UI from network logic, and seamless integration with Material 3 widgets.
- **Cons:** Requires clear state notification boundaries across nested widget trees.
- **Alternatives Considered:** Riverpod and BLoC were evaluated, but Provider offered the optimal balance of readability and fast execution.