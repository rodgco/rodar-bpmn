defmodule Bpmn.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Bpmn.ProcessRegistry},
      Bpmn.Registry,
      {DynamicSupervisor, name: Bpmn.ContextSupervisor, strategy: :one_for_one},
      {DynamicSupervisor, name: Bpmn.ProcessSupervisor, strategy: :one_for_one},
      Bpmn.Port.Supervisor
    ]

    opts = [strategy: :one_for_one, name: Bpmn.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
