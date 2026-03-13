defmodule RodarTraining.Exercises.Ex02ServiceTasks do
  @moduledoc """
  Exercise 2: Service Tasks

  Write service task handlers and wire them to a BPMN process.

  ## Instructions

  1. Implement `ValidateOrder.execute/2`:
     - Check that `"item"` exists (non-nil) and `"quantity"` > 0
     - Return `{:ok, %{"valid" => true}}` if valid
     - Return `{:ok, %{"valid" => false}}` if invalid

  2. Implement `CalculateTotal.execute/2`:
     - Multiply `"quantity"` by `"price"` from the data map
     - Return `{:ok, %{"total" => result}}`

  3. Implement `run/1`:
     - Load `02_order_validation.bpmn`
     - Wire both handlers via handler_map
     - Register as `"order-validation"`
     - Run with the given data map
     - Return `{:ok, pid}`
  """

  defmodule ValidateOrder do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      # TODO: Check that "item" exists and "quantity" > 0
      raise "Not implemented yet"
    end
  end

  defmodule CalculateTotal do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      # TODO: Multiply "quantity" by "price", return %{"total" => result}
      raise "Not implemented yet"
    end
  end

  @spec run(map()) :: {:ok, pid()}
  def run(_data) do
    # TODO: Load BPMN, wire handlers, register, run
    raise "Not implemented yet"
  end
end
