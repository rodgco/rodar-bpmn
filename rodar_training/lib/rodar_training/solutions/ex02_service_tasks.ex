defmodule RodarTraining.Solutions.Ex02ServiceTasks do
  @moduledoc """
  Solution for Exercise 2: Service Tasks
  """

  defmodule ValidateOrder do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, data) do
      item = Map.get(data, "item")
      quantity = Map.get(data, "quantity", 0)

      if item && quantity > 0 do
        {:ok, %{"valid" => true}}
      else
        {:ok, %{"valid" => false}}
      end
    end
  end

  defmodule CalculateTotal do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, data) do
      quantity = Map.get(data, "quantity", 0)
      price = Map.get(data, "price", 0)
      {:ok, %{"total" => quantity * price}}
    end
  end

  def run(data) do
    xml = File.read!("priv/bpmn/02_order_validation.bpmn")

    handler_map = %{
      "Task_Validate" => ValidateOrder,
      "Task_CalculateTotal" => CalculateTotal
    }

    diagram = Rodar.Engine.Diagram.load(xml, handler_map: handler_map)
    [process | _] = diagram.processes

    Rodar.Registry.register("order-validation", process)
    Rodar.Process.create_and_run("order-validation", data)
  end
end
