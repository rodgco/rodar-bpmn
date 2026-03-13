# Chapter 1: Introduction to BPMN & Rodar

Welcome to the Rodar training! This tutorial will teach you how to model and
execute business processes in Elixir using the Rodar BPMN engine.

## What is BPMN?

**BPMN** (Business Process Model and Notation) is a graphical standard for
modeling business workflows. Think of it as a flowchart on steroids — it has
precise semantics for things like:

- **Sequential flow**: Do A, then B, then C
- **Decisions**: If condition is true, go left; otherwise, go right
- **Parallel work**: Do A and B at the same time, then wait for both to finish
- **Human tasks**: Pause the process and wait for someone to take action
- **Events**: React to timers, messages, signals, and errors

BPMN diagrams are stored as XML files (`.bpmn`), which means they are
machine-readable. This is where Rodar comes in.

## What is Rodar?

Rodar is an Elixir library that **parses BPMN 2.0 XML** and **executes the
process** using a token-based flow model. Instead of interpreting a flowchart
visually, Rodar runs it as real code.

### The Token Model

Imagine placing a game token on the start event of your diagram. The engine
moves this token from node to node:

```
[Start] --token--> [Task A] --token--> [Task B] --token--> [End]
```

At a parallel gateway, the token **forks** into multiple child tokens:

```
                    +--> [Task A] --+
[Start] --token--> |               |--> [End]
                    +--> [Task B] --+
```

When all parallel branches complete, the tokens **join** back together.

### Key Concepts

| Concept | What it is |
|---------|-----------|
| **Process** | A BPMN diagram loaded into memory |
| **Context** | A GenServer holding the runtime state (data, metadata, history) |
| **Token** | An execution pointer tracking which node is currently active |
| **Registry** | A store for versioned process definitions |
| **Handler** | Your Elixir module that implements a service task's logic |

### Result Types

Every node execution returns one of these tagged tuples:

| Result | Meaning |
|--------|---------|
| `{:ok, context}` | Node completed successfully |
| `{:error, message}` | Something went wrong |
| `{:manual, context}` | Waiting for external input (e.g., user task) |
| `{:fatal, reason}` | Unrecoverable error |
| `{:not_implemented}` | No handler registered for this element |

## The Basic Workflow

Every Rodar application follows this pattern:

```elixir
# 1. Parse the BPMN XML
xml = File.read!("my_process.bpmn")
diagram = Rodar.Engine.Diagram.load(xml)

# 2. Extract the process
[process | _] = diagram.processes

# 3. Register it (so instances can be created)
Rodar.Registry.register("my-process", process)

# 4. Create and run an instance
{:ok, pid} = Rodar.Process.create_and_run("my-process", %{"key" => "value"})

# 5. Check the result
status = Rodar.Process.status(pid)
```

## BPMN XML Structure

Here's the simplest possible BPMN diagram — a start event connected to an end
event:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<bpmn:definitions xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL"
                  id="Definitions_1"
                  targetNamespace="http://bpmn.io/schema/bpmn">
  <bpmn:process id="hello-world" name="Hello World" isExecutable="true">
    <bpmn:startEvent id="Start_1" name="Start">
      <bpmn:outgoing>Flow_1</bpmn:outgoing>
    </bpmn:startEvent>
    <bpmn:endEvent id="End_1" name="End">
      <bpmn:incoming>Flow_1</bpmn:incoming>
    </bpmn:endEvent>
    <bpmn:sequenceFlow id="Flow_1" sourceRef="Start_1" targetRef="End_1" />
  </bpmn:process>
</bpmn:definitions>
```

Key elements:
- `<bpmn:process>` — The container for all flow elements
- `<bpmn:startEvent>` — Where execution begins
- `<bpmn:endEvent>` — Where execution ends
- `<bpmn:sequenceFlow>` — An arrow connecting two elements
- `<bpmn:outgoing>` / `<bpmn:incoming>` — References to sequence flows

## Prerequisites

Before continuing, make sure you have:

- Elixir ~> 1.16 installed
- OTP 27+ installed
- This training project set up:

```shell
cd rodar_training
mix setup
```

## What's Next?

In the next chapter, you'll load and run your first BPMN process. Head to
[Chapter 2: Your First Process](02_first_process.md).
