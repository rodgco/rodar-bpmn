defmodule RodarTraining.Solutions.Ex03UserTasks do
  @moduledoc """
  Solution for Exercise 3: User Tasks & Resuming
  """

  def start do
    xml = File.read!("priv/bpmn/03_approval_flow.bpmn")
    diagram = Rodar.Engine.Diagram.load(xml)
    [process | _] = diagram.processes

    Rodar.Registry.register("approval-flow", process)

    Rodar.Process.create_and_run("approval-flow", %{
      "requester" => "alice",
      "amount" => 500
    })
  end

  def approve(pid) do
    context = Rodar.Process.get_context(pid)
    process_map = Rodar.Context.get(context, :process)
    task_element = Map.get(process_map, "Task_Review")

    Rodar.Activity.Task.User.resume(task_element, context, %{"approved" => true})
  end
end
