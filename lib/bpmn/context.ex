defmodule Bpmn.Context do
  @moduledoc """
  Bpmn.Engine.Context
  ===================

  The context is an important part of executing a BPMN process. It allows you to keep track
  of any data changes in the execution of the process and well as monitor the execution state
  of your process.

  BPMN execution context for a process. It contains:
  - the list of active nodes for a process
  - the list of completed nodes
  - the initial data received when starting the process
  - the current data in the process
  - the current process
  - extra information about the execution context

  """

  @doc "Start the context process"
  @spec start_link(map(), map()) :: {:ok, pid()}
  def start_link(process, init_data) do
    Agent.start_link(fn ->
      %{
        # initial data for the context passed down from an external system
        init: init_data,
        # current data saved in the context
        data: %{},
        # the process definition to execute on
        process: process,
        # information about each node that is executed
        nodes: %{}
      }
    end)
  end

  @doc """
  Get a key from the current state of the context.
  Use this method to have access to the following:
  - init: the initial data with which the context was started
  - data: the current data saved in the context
  - process: a representation of the current process that is executing
  - nodes: metadata about each node information
  """
  @spec get(pid(), atom()) :: any()
  def get(context, key) do
    Agent.get(context, fn state -> state[key] end)
  end

  @doc """
  Persist a value under the given key in the data state of the context.
  """
  @spec put_data(pid(), any(), any()) :: :ok
  def put_data(context, key, value) do
    Agent.update(context, fn state ->
      update_in(state.data, &Map.put(&1, key, value))
    end)
  end

  @doc """
  Load some information from the current data of the context from the given key
  """
  @spec get_data(pid(), any()) :: any()
  def get_data(context, key) do
    Agent.get(context, fn state -> state.data[key] end)
  end

  @doc """
  Put metadata information for a node.
  """
  @spec put_meta(pid(), any(), any()) :: :ok
  def put_meta(context, key, meta) do
    Agent.update(context, fn state ->
      update_in(state.nodes, &Map.put(&1, key, meta))
    end)
  end

  @doc """
  Get meta data for a node
  """
  @spec get_meta(pid(), any()) :: any()
  def get_meta(context, key) do
    Agent.get(context, fn state -> state.nodes[key] end)
  end

  @doc """
  Check if the node is active
  """
  @spec is_node_active(pid(), any()) :: boolean()
  def is_node_active(context, key) do
    Agent.get(context, fn state -> state.nodes[key].active end)
  end

  @doc """
  Check if the node is completed
  """
  @spec is_node_completed(pid(), any()) :: boolean()
  def is_node_completed(context, key) do
    Agent.get(context, fn state -> state.nodes[key].completed end)
  end
end
