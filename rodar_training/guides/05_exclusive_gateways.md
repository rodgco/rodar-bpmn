# Chapter 5: Exclusive Gateways

Exclusive gateways add **conditional branching** to your processes. Like an
if/else in code, exactly one outgoing path is taken based on conditions.

## The Order Routing Diagram

Open `priv/bpmn/04_order_routing.bpmn`:

```
                              +--> [Express Processing] --+
[Start] --> [Classify] --> <X>                             <X> --> [End]
                              +--> [Standard Processing] --+
```

The `<X>` symbol represents an exclusive gateway. After classifying the order,
the gateway evaluates conditions to choose either express or standard processing.

## How Exclusive Gateways Work

An exclusive gateway:
1. Evaluates the **condition expression** on each outgoing sequence flow
2. Takes the **first** path whose condition evaluates to `true`
3. If no condition matches, takes the **default** path (if one is defined)
4. If no condition matches and no default exists, the process errors

### Conditions in BPMN XML

Conditions are defined on sequence flows using `<conditionExpression>`:

```xml
<bpmn:sequenceFlow id="Flow_Express" sourceRef="GW_Route" targetRef="Task_Express">
  <bpmn:conditionExpression
    xsi:type="bpmn:tFormalExpression"
    language="elixir">data["order_type"] == "express"</bpmn:conditionExpression>
</bpmn:sequenceFlow>
```

The `language` attribute specifies the expression language:
- `"elixir"` — Access process data via `data["key"]`
- `"feel"` — Access process data directly (e.g., `order_type = "express"`)

### Default Flows

A default flow has no condition — it's the fallback:

```xml
<bpmn:exclusiveGateway id="GW_Route" name="Order Type?" default="Flow_Standard">
```

The `default` attribute points to the sequence flow ID that should be taken when
no other condition matches.

## Running the Example

```elixir
handler_map = %{
  "Task_Classify" => RodarTraining.Solutions.ClassifyOrder,
  "Task_Express" => RodarTraining.Solutions.ExpressProcessing,
  "Task_Standard" => RodarTraining.Solutions.StandardProcessing
}

xml = File.read!("priv/bpmn/04_order_routing.bpmn")
diagram = Rodar.Engine.Diagram.load(xml, handler_map: handler_map)
[process | _] = diagram.processes

Rodar.Registry.register("order-routing", process)

# Express order
{:ok, pid} = Rodar.Process.create_and_run("order-routing", %{
  "total" => 1000,
  "shipping" => "overnight"
})

context = Rodar.Process.get_context(pid)
Rodar.Context.get_data(context, "order_type")
# => "express"
Rodar.Context.get_data(context, "processing")
# => "express_handled"
```

## Merge Gateways

After the split, a second exclusive gateway acts as a **merge point**:

```xml
<bpmn:exclusiveGateway id="GW_Merge" name="Merge">
  <bpmn:incoming>Flow_Express_End</bpmn:incoming>
  <bpmn:incoming>Flow_Standard_End</bpmn:incoming>
  <bpmn:outgoing>Flow_End</bpmn:outgoing>
</bpmn:exclusiveGateway>
```

A merge gateway simply passes the token through — it has multiple incoming flows
but only one outgoing flow, and no conditions.

## Exercise

Open `lib/rodar_training/exercises/ex04_exclusive_gateway.ex` and implement:

1. `ClassifyOrder.execute/2` — Set `"order_type"` to `"express"` if
   `"total"` >= 500, otherwise `"standard"`.
2. `ExpressProcessing.execute/2` — Return `%{"processing" => "express"}`.
3. `StandardProcessing.execute/2` — Return `%{"processing" => "standard"}`.
4. `run/1` — Load the BPMN, wire handlers, register, and run. Return `{:ok, pid}`.

```shell
mix test test/rodar_training/exercises/ex04_exclusive_gateway_test.exs
```

## What's Next?

Sometimes you need tasks to run **in parallel**, not one-at-a-time. In
[Chapter 6: Parallel Gateways](06_parallel_gateways.md), you'll learn how to
fork and join execution branches.
