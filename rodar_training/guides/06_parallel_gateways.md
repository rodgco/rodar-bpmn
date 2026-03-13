# Chapter 6: Parallel Gateways

Parallel gateways let you run multiple branches of work **concurrently**. A fork
gateway splits the token into multiple child tokens; a join gateway waits for
all branches to complete before continuing.

## The Parallel Fulfillment Diagram

Open `priv/bpmn/05_parallel_fulfillment.bpmn`:

```
                  +--> [Pack Items]      --+
[Start] --> <+>                            <+> --> [Ship Order] --> [End]
                  +--> [Generate Invoice] --+
```

The `<+>` symbol represents a parallel gateway. After the fork:
- "Pack Items" and "Generate Invoice" execute independently
- Both must complete before "Ship Order" can run

## How Parallel Gateways Work

### Fork (Split)

When a token arrives at a parallel fork gateway, the engine:
1. Creates **child tokens** — one for each outgoing flow
2. Sends each child token down its respective branch
3. Both branches execute (conceptually in parallel)

### Join (Synchronization)

When a child token arrives at a parallel join gateway, the engine:
1. Records that one branch has arrived
2. Checks if **all** expected branches have arrived
3. Only when all branches complete does it release a single token downstream

This means if "Pack Items" finishes first, it waits for "Generate Invoice"
before "Ship Order" can begin.

## Running the Example

```elixir
handler_map = %{
  "Task_Pack" => RodarTraining.Solutions.PackItems,
  "Task_Invoice" => RodarTraining.Solutions.GenerateInvoice,
  "Task_Ship" => RodarTraining.Solutions.ShipOrder
}

xml = File.read!("priv/bpmn/05_parallel_fulfillment.bpmn")
diagram = Rodar.Engine.Diagram.load(xml, handler_map: handler_map)
[process | _] = diagram.processes

Rodar.Registry.register("parallel-fulfillment", process)
{:ok, pid} = Rodar.Process.create_and_run("parallel-fulfillment", %{
  "order_id" => "ORD-001",
  "items" => ["Widget A", "Widget B"]
})

context = Rodar.Process.get_context(pid)
Rodar.Context.get_data(context, "packed")
# => true
Rodar.Context.get_data(context, "invoice_number")
# => "INV-ORD-001"
Rodar.Context.get_data(context, "shipped")
# => true
```

## Data Merging in Parallel Branches

When parallel branches both write to the process data, their results merge. Be
careful about key conflicts — the last branch to complete wins for shared keys.

**Best practice**: Have each branch write to distinct keys.

```elixir
# Branch A writes: %{"packed" => true, "pack_date" => "2024-01-15"}
# Branch B writes: %{"invoice_number" => "INV-001"}
# Result: all keys are present in the merged data
```

## Exercise

Open `lib/rodar_training/exercises/ex05_parallel_gateway.ex` and implement:

1. `PackItems.execute/2` — Return `%{"packed" => true}`.
2. `GenerateInvoice.execute/2` — Generate an invoice number from the order_id.
   Return `%{"invoice_number" => "INV-<order_id>"}`.
3. `ShipOrder.execute/2` — Return `%{"shipped" => true}`.
4. `run/1` — Load, wire, register, run with given data. Return `{:ok, pid}`.

```shell
mix test test/rodar_training/exercises/ex05_parallel_gateway_test.exs
```

## What's Next?

In [Chapter 7: Expressions](07_expressions.md), you'll learn about the two
expression languages Rodar supports — FEEL and Elixir — and how to use them
in gateway conditions and script tasks.
