# Chapter 9: The Workflow API

So far, every example has followed the same pattern: read XML, parse, register,
create instance, resume tasks. The `Rodar.Workflow` module eliminates this
boilerplate.

## Layer 1: The `use` Macro

```elixir
defmodule RodarTraining.Exercises.OrderWorkflow do
  use Rodar.Workflow,
    bpmn_file: "priv/bpmn/07_approval_with_decision.bpmn",
    process_id: "approval-with-decision",
    app_name: "RodarTraining"
end
```

This single `use` declaration injects these functions:

| Function | What it does |
|----------|-------------|
| `setup/0` | Load BPMN, register definition, discover handlers |
| `start_process/1` | Create instance with data map, activate |
| `start_process/0` | Shorthand with empty data |
| `resume_user_task/3` | Resume a user task by `(pid, task_id, input)` |
| `process_status/1` | Get status (with smart completion detection) |
| `process_data/1` | Get the current data map |
| `process_history/1` | Get execution history |

### Usage

```elixir
# Setup once (typically in application startup)
RodarTraining.Exercises.OrderWorkflow.setup()

# Create instances as needed
{:ok, pid} = RodarTraining.Exercises.OrderWorkflow.start_process(%{
  "requester" => "alice",
  "amount" => 500
})

# Check status
:suspended = RodarTraining.Exercises.OrderWorkflow.process_status(pid)

# Resume user tasks by ID
RodarTraining.Exercises.OrderWorkflow.resume_user_task(
  pid, "Task_Approve", %{"approved" => true}
)

# Get results
data = RodarTraining.Exercises.OrderWorkflow.process_data(pid)
```

### Smart Status Detection

`process_status/1` is smarter than `Process.status/1`. When a process is
`:suspended` (because a user task paused during activation), it checks whether
any nodes are still active. If not, the process actually completed:

```elixir
# After resuming the last user task:
Rodar.Process.status(pid)
# => :suspended (the raw status)

RodarTraining.Exercises.OrderWorkflow.process_status(pid)
# => :completed (smart detection — no active nodes left)
```

### Overriding Injected Functions

All injected functions are `defoverridable`:

```elixir
defmodule MyWorkflow do
  use Rodar.Workflow,
    bpmn_file: "priv/bpmn/my_process.bpmn",
    process_id: "my-process"

  def start_process(data) do
    IO.puts("Starting with: #{inspect(data)}")
    super(data)
  end
end
```

## Using the Functional API Directly

If you prefer not to use the macro, call the functions directly:

```elixir
{:ok, diagram} = Rodar.Workflow.setup(
  bpmn_file: "priv/bpmn/07_approval_with_decision.bpmn",
  process_id: "approval-with-decision"
)

{:ok, pid} = Rodar.Workflow.start_process("approval-with-decision", %{
  "requester" => "alice"
})

:suspended = Rodar.Workflow.process_status(pid)

Rodar.Workflow.resume_user_task(pid, "Task_Approve", %{"approved" => true})
```

Note: The functional API takes a `process_id` argument, while the macro version
bakes it in.

## Error Handling

The Workflow API wraps errors with context:

```elixir
case Rodar.Workflow.setup(bpmn_file: "missing.bpmn", process_id: "x") do
  {:ok, diagram} -> diagram
  {:error, msg} -> IO.puts(msg)
  # => "Could not read BPMN file 'missing.bpmn': :enoent"
end

case Rodar.Workflow.resume_user_task(pid, "Bad_Id", %{}) do
  {:ok, result} -> result
  {:error, msg} -> IO.puts(msg)
  # => "Task 'Bad_Id' not found in process"
end
```

## Exercise

Open `lib/rodar_training/exercises/ex07_workflow_api.ex` and implement:

1. Define a module that uses `Rodar.Workflow` with the
   `07_approval_with_decision.bpmn` file.
2. Implement a `run_and_approve/1` function that:
   - Calls `setup/0`
   - Starts a process with the given data
   - Resumes the user task with `%{"approved" => true}`
   - Returns `{:ok, data}` where `data` is the final process data map

```shell
mix test test/rodar_training/exercises/ex07_workflow_api_test.exs
```

## What's Next?

In [Chapter 10: Workflow Server](10_workflow_server.md), you'll learn how to
build a complete domain API with instance tracking using `Rodar.Workflow.Server`.
