defmodule RodarTraining.Exercises.Ex05ParallelGateway do
  @moduledoc """
  Exercise 5: Parallel Gateways

  Run packing and invoicing in parallel, then ship when both are done.

  ## Instructions

  1. Implement `PackItems.execute/2`:
     - Return `%{"packed" => true}`

  2. Implement `GenerateInvoice.execute/2`:
     - Build an invoice number from the order_id: `"INV-<order_id>"`
     - Return `%{"invoice_number" => "INV-<order_id>"}`

  3. Implement `ShipOrder.execute/2`:
     - Return `%{"shipped" => true}`

  4. Implement `run/1`:
     - Load `05_parallel_fulfillment.bpmn`
     - Wire all three handlers
     - Register as `"parallel-fulfillment"`
     - Run with the given data
     - Return `{:ok, pid}`
  """

  defmodule PackItems do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      raise "Not implemented yet"
    end
  end

  defmodule GenerateInvoice do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      # TODO: Build invoice number from order_id
      raise "Not implemented yet"
    end
  end

  defmodule ShipOrder do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      raise "Not implemented yet"
    end
  end

  @spec run(map()) :: {:ok, pid()}
  def run(_data) do
    raise "Not implemented yet"
  end
end
