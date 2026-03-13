defmodule RodarTraining.Solutions.Ex05ParallelGateway do
  @moduledoc """
  Solution for Exercise 5: Parallel Gateways
  """

  defmodule PackItems do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      {:ok, %{"packed" => true}}
    end
  end

  defmodule GenerateInvoice do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, data) do
      order_id = Map.get(data, "order_id", "UNKNOWN")
      {:ok, %{"invoice_number" => "INV-#{order_id}"}}
    end
  end

  defmodule ShipOrder do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      {:ok, %{"shipped" => true}}
    end
  end

  def run(data) do
    xml = File.read!("priv/bpmn/05_parallel_fulfillment.bpmn")

    handler_map = %{
      "Task_Pack" => PackItems,
      "Task_Invoice" => GenerateInvoice,
      "Task_Ship" => ShipOrder
    }

    diagram = Rodar.Engine.Diagram.load(xml, handler_map: handler_map)
    [process | _] = diagram.processes

    Rodar.Registry.register("parallel-fulfillment", process)
    Rodar.Process.create_and_run("parallel-fulfillment", data)
  end
end
