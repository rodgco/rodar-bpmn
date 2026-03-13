defmodule RodarTraining.Solutions.Ex01FirstProcess do
  @moduledoc """
  Solution for Exercise 1: Your First Process
  """

  def run do
    xml = File.read!("priv/bpmn/01_hello_world.bpmn")
    diagram = Rodar.Engine.Diagram.load(xml)
    [process | _] = diagram.processes

    Rodar.Registry.register("hello-world", process)
    {:ok, pid} = Rodar.Process.create_and_run("hello-world", %{})

    status = Rodar.Process.status(pid)
    {:ok, status}
  end
end
