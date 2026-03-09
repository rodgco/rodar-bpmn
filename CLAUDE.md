# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Elixir BPMN 2.0 execution engine (formerly "hashiru-bpmn"). Parses BPMN 2.0 XML diagrams and executes processes using a token-based flow model. Version 0.1.0-dev targeting Elixir ~> 1.16 with OTP 27+.

## Build & Test Commands

```shell
mix deps.get && mix deps.compile && mix compile   # Setup
mix test                                           # Run all tests
mix test test/bpmn/context_test.exs                # Run a single test file
mix test test/bpmn/context_test.exs:10             # Run a single test at line
mix credo                                          # Lint
mix coveralls                                      # Tests with coverage
mix docs                                           # Generate documentation
```

## Architecture

### Token-based Execution Model

All BPMN nodes implement `token_in/2` (some also `token_in/3` with `from_flow` for gateway join tracking). The main dispatcher `Bpmn` (lib/bpmn.ex) routes elements by type to handler modules via `execute/2` (simple) or `execute/3` (with `Bpmn.Token` tracking). `Bpmn.release_token/2` or `release_token/3` passes tokens to the next nodes; `/3` forks child tokens for parallel branches.

Return tuples: `{:ok, context}`, `{:error, msg}`, `{:manual, _}`, `{:fatal, _}`, `{:not_implemented}`.

### Key Modules

- **`Bpmn`** — Main dispatcher; `execute/2` (backward compat) and `execute/3` (with token tracking + execution history). Dispatches to handler modules via private `dispatch/2`.
- **`Bpmn.Token`** — Execution token struct (id, current_node, state, parent_id, created_at). `new/1` generates UUID, `fork/1` creates child tokens for parallel branches.
- **`Bpmn.Context`** — GenServer-based state management with `get/2`, `put_data/3`, `get_data/2`, `put_meta/3`, `get_meta/2`, `record_token/3`, `token_count/2`, `record_activated_paths/3`, `swap_process/2`, `get_state/1`, `start_supervised/2`. Includes execution history API: `record_visit/2`, `record_completion/4`, `get_history/1`, `get_node_history/2`. Handles `{:timer_fired, ...}` and `{:bpmn_event, ...}` via `handle_info`.
- **`Bpmn.Registry`** — GenServer + Elixir Registry for process definition storage. `register/2`, `lookup/1`, `unregister/1`, `list/0`.
- **`Bpmn.Process`** — Process lifecycle GenServer. `start_link/2`, `create_and_run/2`, `activate/1`, `suspend/1`, `resume/1`, `terminate/1`, `status/1`, `get_context/1`.
- **`Bpmn.Event.Bus`** — Registry-based pub/sub using `Bpmn.EventRegistry` (`:duplicate` keys). `subscribe/3`, `unsubscribe/2`, `publish/3` (message=point-to-point, signal/escalation=broadcast), `subscriptions/2`.
- **`Bpmn.Event.Timer`** — ISO 8601 duration parsing (`parse_duration/1`), `schedule/4` via `Process.send_after`, `cancel/1`.
- **`Bpmn.Event.Intermediate.Throw`** — Publishes message/signal/escalation to event bus, releases token.
- **`Bpmn.Event.Intermediate.Catch`** — Subscribes to event bus or schedules timer; returns `{:manual, _}`. Has `resume/3`.
- **`Bpmn.Event.Boundary`** — Full implementation: error (direct activation), message/signal/escalation (event bus), timer (scheduled).
- **`Bpmn.Expression`** — Evaluates condition expressions on sequence flows
- **`Bpmn.Engine.Diagram`** — Parses BPMN 2.0 XML via `erlsom`, returns process maps keyed by element ID. Splits `intermediateThrowEvent` → `:bpmn_event_intermediate_throw`, `intermediateCatchEvent` → `:bpmn_event_intermediate_catch`.
- **`Bpmn.Port.Nodejs`** — GenServer managing a Node.js child process via Erlang ports (JSON protocol with Jason)

### Supervision Tree

`Bpmn.Application` starts: `Bpmn.ProcessRegistry` (Elixir Registry, `:unique`), `Bpmn.EventRegistry` (Elixir Registry, `:duplicate`), `Bpmn.Registry`, `Bpmn.ContextSupervisor` (DynamicSupervisor), `Bpmn.ProcessSupervisor` (DynamicSupervisor), `Bpmn.Port.Supervisor`.

### Module Organization

- `lib/bpmn/activity/` — Tasks (user, script, service, send, receive, manual) and subprocesses (embedded, call activity)
- `lib/bpmn/event/` — Start, end, intermediate (throw/catch), boundary events, event bus, timer utilities
- `lib/bpmn/gateway/` — Exclusive, parallel, inclusive, complex, event-based gateways
- `lib/bpmn/port/` — Node.js port communication and supervisor

### Testing Conventions

Tests rely heavily on doctests embedded in module documentation. Unit tests in `test/` mirror the `lib/` structure. Test modules use `async: true` where possible.

## Commit Message Format

```
<type>(<scope>): <subject>
```

Types: `build`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `style`, `test`
Scopes: `engine`, `plugin`, `scripts`, `api`, `packaging`, `changelog`

Subject: imperative present tense, no capitalized first letter, no trailing dot.

## Branch Strategy

Feature branches off `develop`. PRs target `develop`.
