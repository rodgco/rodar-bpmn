# Chapter 8: Combining It All

Now let's combine everything you've learned into a realistic workflow. This
chapter walks through a purchase approval process with service tasks, a user
task, conditional routing, and multiple end states.

## The Approval With Decision Diagram

Open `priv/bpmn/07_approval_with_decision.bpmn`:

```
                                                +--> [Fulfill Request] --> [End: Fulfilled]
[Start] --> [Prepare] --> [Manager Approval] --> <X>
                                                +--> [Notify Rejection] --> [End: Rejected]
```

This process:
1. **Prepare Request** (service task) — Enrich the request with metadata
2. **Manager Approval** (user task) — Wait for a manager's decision
3. **Decision Gateway** — Branch based on approval
4. **Fulfill** or **Notify Rejection** (service tasks) — Handle the outcome

## The Handlers

### PrepareRequest

```elixir
defmodule RodarTraining.Solutions.PrepareRequest do
  @behaviour Rodar.Activity.Task.Service.Handler

  @impl true
  def execute(_attrs, data) do
    {:ok, %{
      "prepared" => true,
      "prepared_at" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "request_summary" => "#{data["requester"]} requests $#{data["amount"]}"
    }}
  end
end
```

### FulfillRequest

```elixir
defmodule RodarTraining.Solutions.FulfillRequest do
  @behaviour Rodar.Activity.Task.Service.Handler

  @impl true
  def execute(_attrs, data) do
    {:ok, %{"status" => "fulfilled", "fulfilled_for" => data["requester"]}}
  end
end
```

### NotifyRejection

```elixir
defmodule RodarTraining.Solutions.NotifyRejection do
  @behaviour Rodar.Activity.Task.Service.Handler

  @impl true
  def execute(_attrs, data) do
    {:ok, %{"status" => "rejected", "rejection_reason" => "Manager denied request"}}
  end
end
```

## Running the Full Flow

```elixir
handler_map = %{
  "Task_Prepare" => RodarTraining.Solutions.PrepareRequest,
  "Task_Fulfill" => RodarTraining.Solutions.FulfillRequest,
  "Task_Notify" => RodarTraining.Solutions.NotifyRejection
}

xml = File.read!("priv/bpmn/07_approval_with_decision.bpmn")
diagram = Rodar.Engine.Diagram.load(xml, handler_map: handler_map)
[process | _] = diagram.processes

Rodar.Registry.register("approval-with-decision", process)

# Start the process
{:ok, pid} = Rodar.Process.create_and_run("approval-with-decision", %{
  "requester" => "alice",
  "amount" => 500
})

# Process pauses at the user task
Rodar.Process.status(pid)
# => :suspended

# The prepare handler already ran
context = Rodar.Process.get_context(pid)
Rodar.Context.get_data(context, "prepared")
# => true

# Simulate manager approval
process_map = Rodar.Context.get(context, :process)
task_element = Map.get(process_map, "Task_Approve")
Rodar.Activity.Task.User.resume(task_element, context, %{"approved" => true})

# Check the result
Rodar.Context.get_data(context, "status")
# => "fulfilled"
```

### Rejection Path

```elixir
# If the manager rejects:
Rodar.Activity.Task.User.resume(task_element, context, %{"approved" => false})

Rodar.Context.get_data(context, "status")
# => "rejected"
```

## Pattern: Checking Which End Event Was Reached

The execution history tells you which nodes were visited:

```elixir
history = Rodar.Context.get_history(context)
end_events = Enum.filter(history, fn entry ->
  String.starts_with?(entry.node_id, "End_")
end)
```

## Exercise

Open `lib/rodar_training/exercises/ex06_combined_workflow.ex` and implement:

1. `PrepareRequest.execute/2` — Set `"prepared"` to `true` and build a
   `"request_summary"` from the data.
2. `FulfillRequest.execute/2` — Return `%{"status" => "fulfilled"}`.
3. `NotifyRejection.execute/2` — Return `%{"status" => "rejected"}`.
4. `run/1` — Load, wire, register, and run. Return `{:ok, pid}`.
5. `approve/1` — Resume the user task with `%{"approved" => true}`.
6. `reject/1` — Resume the user task with `%{"approved" => false}`.

```shell
mix test test/rodar_training/exercises/ex06_combined_workflow_test.exs
```

## What's Next?

In [Chapter 9: The Workflow API](09_workflow_api.md), you'll learn how to
eliminate boilerplate with the `Rodar.Workflow` module and its `use` macro.
