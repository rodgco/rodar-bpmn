defmodule RodarTraining.Solutions.Ex04ExclusiveGateway do
  @moduledoc """
  Solution for Exercise 4: Exclusive Gateways
  """

  defmodule ClassifyOrder do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, data) do
      total = Map.get(data, "total", 0)

      if total >= 500 do
        {:ok, %{"order_type" => "express"}}
      else
        {:ok, %{"order_type" => "standard"}}
      end
    end
  end

  defmodule ExpressProcessing do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      {:ok, %{"processing" => "express"}}
    end
  end

  defmodule StandardProcessing do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      {:ok, %{"processing" => "standard"}}
    end
  end

  def run(data) do
    xml = File.read!("priv/bpmn/04_order_routing.bpmn")

    handler_map = %{
      "Task_Classify" => ClassifyOrder,
      "Task_Express" => ExpressProcessing,
      "Task_Standard" => StandardProcessing
    }

    diagram = Rodar.Engine.Diagram.load(xml, handler_map: handler_map)
    [process | _] = diagram.processes

    Rodar.Registry.register("order-routing", process)
    Rodar.Process.create_and_run("order-routing", data)
  end
end
