defmodule RodarTraining.Solutions.Ex07WorkflowApi do
  @moduledoc """
  Solution for Exercise 7: The Workflow API
  """

  def run_and_approve(data) do
    handler_map = %{
      "Task_Prepare" => RodarTraining.Solutions.Ex06CombinedWorkflow.PrepareRequest,
      "Task_Fulfill" => RodarTraining.Solutions.Ex06CombinedWorkflow.FulfillRequest,
      "Task_Notify" => RodarTraining.Solutions.Ex06CombinedWorkflow.NotifyRejection
    }

    {:ok, _diagram} = Rodar.Workflow.setup(
      bpmn_file: "priv/bpmn/07_approval_with_decision.bpmn",
      process_id: "approval-with-decision",
      handler_map: handler_map
    )

    {:ok, pid} = Rodar.Workflow.start_process("approval-with-decision", data)

    Rodar.Workflow.resume_user_task(pid, "Task_Approve", %{"approved" => true})

    data = Rodar.Workflow.process_data(pid)
    {:ok, data}
  end
end
