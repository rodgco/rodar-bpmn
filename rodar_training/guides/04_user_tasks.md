# Chapter 4: User Tasks & Resuming

User tasks represent work that requires **human intervention**. When the engine
reaches a user task, it pauses execution and waits for someone to provide input.

## The Approval Flow Diagram

Open `priv/bpmn/03_approval_flow.bpmn`:

```
[Start] --> [Manager Review] --> [End]
```

A simple flow with one user task. When executed, the process will **suspend** at
"Manager Review" and wait for input.

## How User Tasks Work

1. The engine reaches the user task node
2. The task returns `{:manual, context}` — execution pauses
3. The process status becomes `:suspended`
4. **Your application** collects the human input (via a web form, API, CLI, etc.)
5. You call `resume` with the input data
6. Execution continues to the next node

## Running a User Task Process

```elixir
xml = File.read!("priv/bpmn/03_approval_flow.bpmn")
diagram = Rodar.Engine.Diagram.load(xml)
[process | _] = diagram.processes

Rodar.Registry.register("approval-flow", process)
{:ok, pid} = Rodar.Process.create_and_run("approval-flow", %{
  "requester" => "alice",
  "amount" => 500
})

# The process is suspended, waiting at the user task
Rodar.Process.status(pid)
# => :suspended
```

## Resuming a User Task

To resume, use `Rodar.Activity.Task.User.resume/3`:

```elixir
context = Rodar.Process.get_context(pid)
process_map = Rodar.Context.get(context, :process)
task_element = Map.get(process_map, "Task_Review")

Rodar.Activity.Task.User.resume(task_element, context, %{
  "decision" => "approved",
  "reviewer" => "bob"
})
```

This:
1. Merges the input data into the process context
2. Releases the token to continue along the outgoing flow
3. Execution continues to the end event

After resuming:

```elixir
# Note: status may still show :suspended even though the process completed.
# Use Rodar.Workflow.process_status/1 for smart completion detection.

context = Rodar.Process.get_context(pid)
Rodar.Context.get_data(context, "decision")
# => "approved"
```

## The Easier Way: Workflow API

The low-level resume is verbose. The `Rodar.Workflow` module simplifies it:

```elixir
Rodar.Workflow.setup(
  bpmn_file: "priv/bpmn/03_approval_flow.bpmn",
  process_id: "approval-flow"
)

{:ok, pid} = Rodar.Workflow.start_process("approval-flow", %{
  "requester" => "alice"
})

# Resume with a single call
Rodar.Workflow.resume_user_task(pid, "Task_Review", %{
  "decision" => "approved"
})
```

We'll cover the Workflow API in depth in Chapter 9.

## Common Mistakes

**Mistake 1: Using `Process.resume/1` to continue from a user task**

```elixir
# WRONG — this only changes status from :suspended to :running
# It does NOT release the token or continue execution
Rodar.Process.resume(pid)
```

`Process.resume/1` is for resuming a **suspended** process (e.g., after
`Process.suspend/1`), not for completing a user task.

**Mistake 2: Forgetting to provide the task element**

The resume function needs the actual BPMN element (the `{type, attrs}` tuple),
not just the task ID string. You must look it up in the process map.

## Exercise

Open `lib/rodar_training/exercises/ex03_user_tasks.ex` and implement:

1. `start/0` — Load `03_approval_flow.bpmn`, register, and run with sample data.
   Return `{:ok, pid}`.
2. `approve/1` — Given a process pid, resume the `"Task_Review"` user task with
   `%{"approved" => true}`. Return `{:ok, context}`.

```shell
mix test test/rodar_training/exercises/ex03_user_tasks_test.exs
```

## What's Next?

In [Chapter 5: Exclusive Gateways](05_exclusive_gateways.md), you'll learn
how to add conditional branching to your processes.
