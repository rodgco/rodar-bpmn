# Rodar Training

A hands-on tutorial for the [Rodar](https://github.com/rodar-project/rodar) BPMN engine.

Learn how to model and execute business processes in Elixir — from your first
"hello world" process to a complete order management system with service tasks,
user tasks, gateways, expressions, and the high-level Workflow API.

## Getting Started

```shell
cd rodar_training
mix setup
```

## Tutorial Structure

Each chapter has three components:
- A **guide** in `guides/` explaining the concepts
- A **BPMN diagram** in `priv/bpmn/` used in the exercises
- An **exercise** in `lib/rodar_training/exercises/` with stubs to fill in

Complete solutions are in `lib/rodar_training/solutions/`.

### Chapters

| # | Topic | Guide | Exercise |
|---|-------|-------|----------|
| 1 | Introduction to BPMN & Rodar | [01_introduction.md](guides/01_introduction.md) | — |
| 2 | Your First Process | [02_first_process.md](guides/02_first_process.md) | `ex01_first_process.ex` |
| 3 | Service Tasks | [03_service_tasks.md](guides/03_service_tasks.md) | `ex02_service_tasks.ex` |
| 4 | User Tasks & Resuming | [04_user_tasks.md](guides/04_user_tasks.md) | `ex03_user_tasks.ex` |
| 5 | Exclusive Gateways | [05_exclusive_gateways.md](guides/05_exclusive_gateways.md) | `ex04_exclusive_gateway.ex` |
| 6 | Parallel Gateways | [06_parallel_gateways.md](guides/06_parallel_gateways.md) | `ex05_parallel_gateway.ex` |
| 7 | Expressions (FEEL & Elixir) | [07_expressions.md](guides/07_expressions.md) | (IEx exploration) |
| 8 | Combining It All | [08_combining_it_all.md](guides/08_combining_it_all.md) | `ex06_combined_workflow.ex` |
| 9 | The Workflow API | [09_workflow_api.md](guides/09_workflow_api.md) | `ex07_workflow_api.ex` |
| 10 | Workflow Server | [10_workflow_server.md](guides/10_workflow_server.md) | `ex08_workflow_server.ex` |

## Running Tests

```shell
# Run all exercise tests (validates the solutions)
mix test

# Run a specific exercise test
mix test test/rodar_training/exercises/ex01_first_process_test.exs
```

To test your own solutions, edit the `@module` attribute at the top of each test
file to point to your exercise module instead of the solution module.

## Prerequisites

- Elixir ~> 1.16
- OTP 27+
- Basic Elixir knowledge (modules, functions, pattern matching, GenServer concepts)

## What You'll Learn

- How BPMN diagrams map to executable processes
- Parsing BPMN XML and registering process definitions
- Writing service task handlers (`Service.Handler` behaviour)
- Handling user tasks with suspend/resume patterns
- Routing with exclusive gateways and condition expressions
- Parallelizing work with parallel gateways
- Using FEEL and Elixir expression languages
- Eliminating boilerplate with `Rodar.Workflow`
- Building production-ready domain APIs with `Rodar.Workflow.Server`
