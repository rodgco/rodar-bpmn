# Chapter 10: Building a Domain API with Workflow.Server

`Rodar.Workflow.Server` (Layer 2) adds a GenServer on top of the Workflow API,
giving you instance tracking with sequential IDs and domain-specific status
mapping. This is the pattern for building production-ready workflow services.

## The Complete Order Process

Open `priv/bpmn/08_complete_order.bpmn`:

```
[Order Placed] --> [Validate] --> <X> Valid? --> [Check Inventory] --> <X> In Stock?
                                  |                                     |
                                  +--> [End: Invalid]                   +--> [End: Out Of Stock]
                                                                        |
              [End: Fulfilled] <-- [Send Confirmation] <-- <+> <--------+
                                                            |     +--> [Charge Payment]
              [End: Denied] <-- <X> Approved? <-- [Manager Approval]
                                 |                          +--> [Pack And Ship]
                                 +--> <+> Fork ----------->-+
```

This combines everything: service tasks, user tasks, exclusive gateways,
parallel gateways, and multiple end states.

## Defining a Workflow Server

```elixir
defmodule RodarTraining.OrderManager do
  use Rodar.Workflow.Server,
    bpmn_file: "priv/bpmn/08_complete_order.bpmn",
    process_id: "complete-order",
    app_name: "RodarTraining"

  @impl Rodar.Workflow.Server
  def init_data(params, instance_id) do
    %{
      "order_id" => "ORD-#{instance_id}",
      "customer" => params["customer"],
      "item" => params["item"],
      "quantity" => params["quantity"],
      "price" => params["price"]
    }
  end

  @impl Rodar.Workflow.Server
  def map_status(:suspended), do: :pending_approval
  def map_status(:completed), do: :fulfilled
  def map_status(other), do: other

  # Domain API
  def create_order(params), do: create_instance(params)
  def approve(id), do: complete_task(id, "Task_ManagerApproval", %{"approved" => true})
  def deny(id), do: complete_task(id, "Task_ManagerApproval", %{"approved" => false})
  def orders, do: list_instances()
  def order(id), do: get_instance(id)
end
```

### Required: `init_data/2`

This callback transforms raw params into the BPMN process data map. It receives:
- `params` — Whatever was passed to `create_instance/1`
- `instance_id` — A sequential integer (1, 2, 3, ...)

### Optional: `map_status/1`

Translates BPMN status atoms to domain terms. Without it, you get raw BPMN
statuses (`:created`, `:running`, `:suspended`, `:completed`, etc.).

## Starting the Server

Add it to your supervision tree:

```elixir
# In your Application module or test setup
{:ok, _pid} = RodarTraining.OrderManager.start_link([])
```

`start_link/1` calls `setup/0` during `init/1` — it loads the BPMN file and
registers the process definition automatically.

## Using the Domain API

```elixir
# Create an order
{:ok, instance} = RodarTraining.OrderManager.create_order(%{
  "customer" => "Alice",
  "item" => "Premium Widget",
  "quantity" => 5,
  "price" => 100
})

instance.id       # => 1
instance.status   # => :pending_approval (mapped from :suspended)

# List all orders
orders = RodarTraining.OrderManager.orders()
# => [%{id: 1, status: :pending_approval, ...}]

# Approve the order
{:ok, updated} = RodarTraining.OrderManager.approve(1)
updated.status    # => :fulfilled (mapped from :completed)

# Get a specific order
{:ok, order} = RodarTraining.OrderManager.order(1)
```

## Instance Tracking

The server maintains a map of all instances with:
- `:id` — Sequential integer
- `:process_pid` — The underlying `Rodar.Process` PID
- `:status` — The mapped status
- `:created_at` — Timestamp

`list_instances/0` returns instances sorted newest-first.

## Message Isolation

The server uses `{:__workflow__, action, ...}` tuple tags for internal messages.
This means you can safely add your own `handle_call`, `handle_cast`, and
`handle_info` callbacks without conflicts:

```elixir
defmodule MyServer do
  use Rodar.Workflow.Server, ...

  # Your own GenServer callbacks — no conflicts
  def handle_call(:custom_query, _from, state) do
    {:reply, :ok, state}
  end
end
```

## Exercise

Open `lib/rodar_training/exercises/ex08_workflow_server.ex` and implement:

1. Define an `OrderManager` module using `Rodar.Workflow.Server`
2. Implement `init_data/2` — Create an order data map with `"order_id"`,
   `"customer"`, `"item"`, `"quantity"`, `"price"`
3. Implement `map_status/1` — Map `:suspended` to `:pending_approval` and
   `:completed` to `:fulfilled`
4. Add domain wrappers: `create_order/1`, `approve/1`, `deny/1`

```shell
mix test test/rodar_training/exercises/ex08_workflow_server_test.exs
```

## Congratulations!

You've completed the Rodar training. You now know how to:

- Parse and run BPMN diagrams
- Write service task handlers
- Handle user tasks with suspend/resume
- Route execution with exclusive gateways
- Parallelize work with parallel gateways
- Use FEEL and Elixir expressions
- Eliminate boilerplate with the Workflow API
- Build production-ready domain APIs with Workflow.Server

## Where to Go From Here

- **Events**: Explore timer, message, signal, and boundary events
- **Persistence**: Save and restore process state with the persistence adapter
- **Versioning**: Manage multiple versions of process definitions
- **Observability**: Monitor running processes with telemetry and the dashboard API
- **Scaffolding**: Generate handler stubs from BPMN files with `mix rodar.scaffold`
- **Collaboration**: Orchestrate multiple participants with message flows

Check the [Rodar documentation](https://hexdocs.pm/rodar) for the full API
reference.
