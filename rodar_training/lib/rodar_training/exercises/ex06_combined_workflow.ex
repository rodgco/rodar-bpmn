defmodule RodarTraining.Exercises.Ex06CombinedWorkflow do
  @moduledoc """
  Exercise 6: Combining It All

  Build a complete approval workflow with service tasks, a user task,
  conditional routing, and multiple end states.

  ## Instructions

  1. Implement `PrepareRequest.execute/2`:
     - Set `"prepared"` to `true`
     - Build `"request_summary"` as `"<requester> requests $<amount>"`
     - Return the result map

  2. Implement `FulfillRequest.execute/2`:
     - Return `%{"status" => "fulfilled"}`

  3. Implement `NotifyRejection.execute/2`:
     - Return `%{"status" => "rejected"}`

  4. Implement `run/1`:
     - Load `07_approval_with_decision.bpmn`
     - Wire all three handlers (Task_Prepare, Task_Fulfill, Task_Notify)
     - Register as `"approval-with-decision"`
     - Run with the given data
     - Return `{:ok, pid}`

  5. Implement `approve/1`:
     - Resume `"Task_Approve"` with `%{"approved" => true}`

  6. Implement `reject/1`:
     - Resume `"Task_Approve"` with `%{"approved" => false}`
  """

  defmodule PrepareRequest do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      raise "Not implemented yet"
    end
  end

  defmodule FulfillRequest do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      raise "Not implemented yet"
    end
  end

  defmodule NotifyRejection do
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

  @spec approve(pid()) :: any()
  def approve(_pid) do
    raise "Not implemented yet"
  end

  @spec reject(pid()) :: any()
  def reject(_pid) do
    raise "Not implemented yet"
  end
end
