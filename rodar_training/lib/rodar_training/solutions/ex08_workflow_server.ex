defmodule RodarTraining.Solutions.Ex08WorkflowServer do
  @moduledoc """
  Solution for Exercise 8: Workflow Server
  """

  defmodule OrderManager do
    use Rodar.Workflow.Server,
      bpmn_file: "priv/bpmn/08_complete_order.bpmn",
      process_id: "complete-order"

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

    def create_order(params), do: create_instance(params)

    def approve(id),
      do: complete_task(id, "Task_ManagerApproval", %{"approved" => true})

    def deny(id),
      do: complete_task(id, "Task_ManagerApproval", %{"approved" => false})
  end
end
