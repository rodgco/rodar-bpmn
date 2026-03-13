defmodule RodarTraining.Exercises.Ex08WorkflowServer do
  @moduledoc """
  Exercise 8: Workflow Server

  Build a domain API with `Rodar.Workflow.Server`.

  ## Instructions

  Define an `OrderManager` module using `use Rodar.Workflow.Server` with:
  - `bpmn_file: "priv/bpmn/08_complete_order.bpmn"`
  - `process_id: "complete-order"`

  Required callbacks:

  1. `init_data/2` — Transform params + instance_id into process data:
     - `"order_id"` => `"ORD-<instance_id>"`
     - `"customer"` => from params
     - `"item"` => from params
     - `"quantity"` => from params
     - `"price"` => from params

  2. `map_status/1`:
     - `:suspended` => `:pending_approval`
     - `:completed` => `:fulfilled`
     - Everything else => pass through

  Domain wrappers:

  3. `create_order/1` — delegates to `create_instance/1`
  4. `approve/1` — completes `"Task_ManagerApproval"` with `%{"approved" => true}`
  5. `deny/1` — completes `"Task_ManagerApproval"` with `%{"approved" => false}`
  """

  # TODO: Define OrderManager module
  # defmodule OrderManager do
  #   use Rodar.Workflow.Server,
  #     bpmn_file: "priv/bpmn/08_complete_order.bpmn",
  #     process_id: "complete-order"
  #
  #   @impl Rodar.Workflow.Server
  #   def init_data(params, instance_id) do
  #     ...
  #   end
  #
  #   @impl Rodar.Workflow.Server
  #   def map_status(:suspended), do: :pending_approval
  #   def map_status(:completed), do: :fulfilled
  #   def map_status(other), do: other
  #
  #   def create_order(params), do: create_instance(params)
  #   def approve(id), do: complete_task(id, "Task_ManagerApproval", %{"approved" => true})
  #   def deny(id), do: complete_task(id, "Task_ManagerApproval", %{"approved" => false})
  # end
end
