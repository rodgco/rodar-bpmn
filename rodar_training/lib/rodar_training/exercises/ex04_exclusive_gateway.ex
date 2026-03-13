defmodule RodarTraining.Exercises.Ex04ExclusiveGateway do
  @moduledoc """
  Exercise 4: Exclusive Gateways

  Route orders through different processing paths based on their total.

  ## Instructions

  1. Implement `ClassifyOrder.execute/2`:
     - If `"total"` >= 500, return `%{"order_type" => "express"}`
     - Otherwise, return `%{"order_type" => "standard"}`

  2. Implement `ExpressProcessing.execute/2`:
     - Return `%{"processing" => "express"}`

  3. Implement `StandardProcessing.execute/2`:
     - Return `%{"processing" => "standard"}`

  4. Implement `run/1`:
     - Load `04_order_routing.bpmn`
     - Wire all three handlers
     - Register as `"order-routing"`
     - Run with the given data
     - Return `{:ok, pid}`
  """

  defmodule ClassifyOrder do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      # TODO: Classify based on total
      raise "Not implemented yet"
    end
  end

  defmodule ExpressProcessing do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      raise "Not implemented yet"
    end
  end

  defmodule StandardProcessing do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      raise "Not implemented yet"
    end
  end

  @spec run(map()) :: {:ok, pid()}
  def run(_data) do
    # TODO: Load BPMN, wire handlers, register, run
    raise "Not implemented yet"
  end
end
