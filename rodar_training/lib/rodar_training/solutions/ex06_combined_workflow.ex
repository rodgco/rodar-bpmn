defmodule RodarTraining.Solutions.Ex06CombinedWorkflow do
  @moduledoc """
  Solution for Exercise 6: Combining It All
  """

  defmodule PrepareRequest do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, data) do
      requester = Map.get(data, "requester", "unknown")
      amount = Map.get(data, "amount", 0)

      {:ok, %{
        "prepared" => true,
        "request_summary" => "#{requester} requests $#{amount}"
      }}
    end
  end

  defmodule FulfillRequest do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      {:ok, %{"status" => "fulfilled"}}
    end
  end

  defmodule NotifyRejection do
    @behaviour Rodar.Activity.Task.Service.Handler

    @impl true
    def execute(_attrs, _data) do
      {:ok, %{"status" => "rejected"}}
    end
  end

  def run(data) do
    xml = File.read!("priv/bpmn/07_approval_with_decision.bpmn")

    handler_map = %{
      "Task_Prepare" => PrepareRequest,
      "Task_Fulfill" => FulfillRequest,
      "Task_Notify" => NotifyRejection
    }

    diagram = Rodar.Engine.Diagram.load(xml, handler_map: handler_map)
    [process | _] = diagram.processes

    Rodar.Registry.register("approval-with-decision", process)
    Rodar.Process.create_and_run("approval-with-decision", data)
  end

  def approve(pid) do
    context = Rodar.Process.get_context(pid)
    process_map = Rodar.Context.get(context, :process)
    task_element = Map.get(process_map, "Task_Approve")
    Rodar.Activity.Task.User.resume(task_element, context, %{"approved" => true})
  end

  def reject(pid) do
    context = Rodar.Process.get_context(pid)
    process_map = Rodar.Context.get(context, :process)
    task_element = Map.get(process_map, "Task_Approve")
    Rodar.Activity.Task.User.resume(task_element, context, %{"approved" => false})
  end
end
