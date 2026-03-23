# API Changes & Migration Guide

## Overview
This document outlines the API changes introduced to support the enhanced `ChatBIAgent` streaming capabilities, including structured "Thinking" process, SQL generation insights, and execution results.

## Backend Changes

### 1. `ChatBIAgent` Streaming Interface (`agent/graph.py`)
The `astream` method now yields structured Server-Sent Events (SSE) with the following types:

- **`thinking`**: Represents a step in the agent's reasoning process.
  - Payload: `{ "type": "thinking", "content": "..." }`
- **`sql_generated`**: Emitted when SQL is generated. Now includes the "thought" process behind the SQL.
  - Payload: `{ "type": "sql_generated", "content": "SELECT...", "thought": "Reasoning..." }`
- **`execution_result`**: Emitted after SQL execution.
  - Payload: `{ "type": "execution_result", "content": "Query successful..." }`
- **`final_answer`**: The final response to the user.
  - Payload: `{ "type": "final_answer", "content": "..." }`

### 2. Application Endpoint (`app.py`)
The `query_database_stream` endpoint has been updated to handle these new event types and correctly aggregate the "thinking" process for the final history record.

- **Compatibility**: The endpoint remains backward compatible with clients that only consume `final_answer`, but full UI features require handling the new event types.
- **State Management**: The "thinking" content is now accumulated from both `thinking` events and the `thought` field of `sql_generated` events.

### 3. Response Models (`routes/chat.py`)
`SessionResponse` and `MessageResponse` models now define `created_at` and `updated_at` as optional (`datetime | None`). This improves resilience against data inconsistencies and prevents 500 errors.

## Frontend Changes

### 1. Type Definitions (`frontend/src/types/api.ts`)
Updated `StreamEvent` type union to include:
```typescript
export type StreamEvent = 
  | { type: 'thinking'; content: string }
  | { type: 'sql_generated'; content: string; thought?: string; metadata?: any }
  | { type: 'execution_result'; content: string }
  | { type: 'final_answer'; content: string; thinking?: string; sql?: string }
  // ...
```

### 2. Component Logic (`frontend/src/components/MainPlayground.tsx`)
- **State Handling**: Refactored to track `thinking`, `sqlThought`, and `sql` separately in the message state.
- **UI**: Added a collapsible "Thinking" section that displays both the general reasoning and the specific SQL generation thought process.
- **Status Updates**: The message status now reflects the current stage (`Thinking...`, `SQL Generated`, `Execution Successful`).

## Migration Steps for Clients

1. **Update Event Listeners**: Ensure your SSE client handles `thinking`, `sql_generated`, and `execution_result` events.
2. **Display Thinking**: Render the `thinking` content in a collapsible or secondary view to provide transparency into the AI's logic.
3. **Handle SQL Metadata**: Use the `thought` field in `sql_generated` to explain *why* a specific query was constructed.

## Testing & Validation

- **Backend Compatibility**: Verified via `tests/test_app_compatibility.py`.
- **Frontend End-to-End**: Verified via `tests/chat-flow.spec.ts` (Playwright), covering the full streaming lifecycle.
