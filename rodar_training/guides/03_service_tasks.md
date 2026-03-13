# Chapter 3: Service Tasks

Service tasks are the workhorses of BPMN — they represent automated work
performed by the system. In Rodar, you implement service tasks by writing
handler modules.

## The Order Validation Diagram

Open `priv/bpmn/02_order_validation.bpmn`:

```
[Start] --> [Validate Order] --> [Calculate Total] --> [End]
```

Two service tasks in sequence: first validate the order, then calculate the
total.

## Writing a Service Task Handler

Service task handlers implement the `Rodar.Activity.Task.Service.Handler`
behaviour. They have a single callback:

```elixir
@callback execute(attrs :: map(), data :: map()) :: {:ok, map()} | {:error, term()}
```

- `attrs` — The BPMN element attributes (id, name, etc.)
- `data` — The current process data as a map
- Return `{:ok, result_map}` — the result map gets **merged** into the process data
- Return `{:error, reason}` — stops execution with an error

### Validate Order Handler

```elixir
defmodule RodarTraining.Exercises.ValidateOrder do
  @behaviour Rodar.Activity.Task.Service.Handler

  @impl true
  def execute(_attrs, data) do
    item = Map.get(data, "item")
    quantity = Map.get(data, "quantity", 0)

    if item && quantity > 0 do
      {:ok, %{"valid" => true}}
    else
      {:ok, %{"valid" => false, "error" => "Missing item or invalid quantity"}}
    end
  end
end
```

Notice:
- We read from the `data` map (the current process state)
- We return `{:ok, result_map}` — the engine merges this into the process data
- After this handler runs, `data["valid"]` will be `true` or `false`

### Calculate Total Handler

```elixir
defmodule RodarTraining.Exercises.CalculateTotal do
  @behaviour Rodar.Activity.Task.Service.Handler

  @impl true
  def execute(_attrs, data) do
    quantity = Map.get(data, "quantity", 0)
    price = Map.get(data, "price", 0)
    {:ok, %{"total" => quantity * price}}
  end
end
```

## Wiring Handlers to Tasks

Handlers don't automatically connect to BPMN tasks — you need to **wire** them.
The most common approach is `handler_map` at parse time:

```elixir
xml = File.read!("priv/bpmn/02_order_validation.bpmn")

handler_map = %{
  "Task_Validate" => RodarTraining.Exercises.ValidateOrder,
  "Task_CalculateTotal" => RodarTraining.Exercises.CalculateTotal
}

diagram = Rodar.Engine.Diagram.load(xml, handler_map: handler_map)
```

The keys are the **BPMN element IDs** (the `id` attribute in the XML). The
values are handler module names.

### Alternative: TaskRegistry

You can also register handlers at runtime:

```elixir
Rodar.TaskRegistry.register("Task_Validate", RodarTraining.Exercises.ValidateOrder)
```

**Lookup priority**: handler_map (inline) > TaskRegistry > `{:not_implemented}`.

## Running the Process

```elixir
xml = File.read!("priv/bpmn/02_order_validation.bpmn")

diagram = Rodar.Engine.Diagram.load(xml, handler_map: %{
  "Task_Validate" => RodarTraining.Exercises.ValidateOrder,
  "Task_CalculateTotal" => RodarTraining.Exercises.CalculateTotal
})

[process | _] = diagram.processes
Rodar.Registry.register("order-validation", process)

{:ok, pid} = Rodar.Process.create_and_run("order-validation", %{
  "item" => "Widget",
  "quantity" => 3,
  "price" => 25
})

Rodar.Process.status(pid)
# => :completed

context = Rodar.Process.get_context(pid)
Rodar.Context.get_data(context, "valid")
# => true
Rodar.Context.get_data(context, "total")
# => 75
```

## What Happens Without Handlers?

If you forget to wire a handler (or wire the wrong ID), the service task returns
`{:not_implemented}`. The process won't crash, but the task won't do anything
useful.

## Exercise

Open `lib/rodar_training/exercises/ex02_service_tasks.ex` and implement:

1. `ValidateOrder.execute/2` — Check that `"item"` exists and `"quantity"` > 0.
   Return `%{"valid" => true/false}`.
2. `CalculateTotal.execute/2` — Multiply `"quantity"` by `"price"`.
   Return `%{"total" => result}`.
3. `run/1` — Load the BPMN, wire both handlers, register, run with the given
   data, and return `{:ok, pid}`.

```shell
mix test test/rodar_training/exercises/ex02_service_tasks_test.exs
```

## What's Next?

Not all tasks can be automated. In [Chapter 4: User Tasks](04_user_tasks.md),
you'll learn how to pause a process and wait for human input.
