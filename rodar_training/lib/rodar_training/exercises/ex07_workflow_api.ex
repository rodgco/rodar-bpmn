defmodule RodarTraining.Exercises.Ex07WorkflowApi do
  @moduledoc """
  Exercise 7: The Workflow API

  Use `Rodar.Workflow` to eliminate boilerplate.

  ## Instructions

  1. Define `ApprovalWorkflow` using `use Rodar.Workflow` with:
     - `bpmn_file: "priv/bpmn/07_approval_with_decision.bpmn"`
     - `process_id: "approval-with-decision"`

  2. Implement `run_and_approve/1` in the outer module:
     - Wire handlers for Task_Prepare, Task_Fulfill, Task_Notify
       (you can reuse your solutions or the ones from solutions/)
     - Call `ApprovalWorkflow.setup()`
     - Start a process with the given data
     - Resume the user task `"Task_Approve"` with `%{"approved" => true}`
     - Return `{:ok, data}` where data is the final process data

  ## Hints

  - You need to wire handlers separately (via handler_map or TaskRegistry)
    since the Workflow macro's setup only handles auto-discovered handlers.
  - For this exercise, use `Rodar.Workflow.setup/1` (functional API) instead
    of the macro's `setup/0` so you can pass the handler_map.
  """

  # TODO: Define ApprovalWorkflow module with `use Rodar.Workflow`
  # defmodule ApprovalWorkflow do
  #   use Rodar.Workflow,
  #     bpmn_file: "priv/bpmn/07_approval_with_decision.bpmn",
  #     process_id: "approval-with-decision"
  # end

  @spec run_and_approve(map()) :: {:ok, map()}
  def run_and_approve(_data) do
    # TODO: Setup, start, approve, return final data
    raise "Not implemented yet"
  end
end
