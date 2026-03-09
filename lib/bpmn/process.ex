defmodule Bpmn.Process do
  @moduledoc """
  Process lifecycle management for BPMN process instances.

  Manages the full lifecycle of a BPMN process instance: creation, activation,
  suspension, resumption, and termination. Each process instance runs as a
  GenServer that owns a supervised context and tracks execution status.

  ## Status transitions

      :created → :running → :completed
                         → :error
      :running → :suspended → :running (resume)
      any     → :terminated
  """

  use GenServer

  @type status :: :created | :running | :suspended | :completed | :terminated | :error

  # --- Client API ---

  @doc """
  Start a process instance from a registered definition.

  Looks up the process definition in `Bpmn.Registry`, creates a supervised
  context, and sets status to `:created`.
  """
  @spec start_link({String.t(), map()} | String.t(), map()) :: {:ok, pid()} | {:error, any()}
  def start_link({process_id, init_data}) do
    start_link(process_id, init_data)
  end

  def start_link(process_id, init_data \\ %{}) do
    GenServer.start_link(__MODULE__, {process_id, init_data})
  end

  @doc """
  Create a process instance under the `Bpmn.ProcessSupervisor` and activate it.
  """
  @spec create_and_run(String.t(), map()) :: {:ok, pid()} | {:error, any()}
  def create_and_run(process_id, init_data \\ %{}) do
    case DynamicSupervisor.start_child(
           Bpmn.ProcessSupervisor,
           {__MODULE__, {process_id, init_data}}
         ) do
      {:ok, pid} ->
        activate(pid)
        {:ok, pid}

      error ->
        error
    end
  end

  @doc """
  Activate a created process instance. Finds the start event and begins execution.
  """
  @spec activate(pid()) :: :ok | {:error, any()}
  def activate(pid) do
    GenServer.call(pid, :activate, :infinity)
  end

  @doc """
  Suspend a running process instance.
  """
  @spec suspend(pid()) :: :ok | {:error, any()}
  def suspend(pid) do
    GenServer.call(pid, :suspend)
  end

  @doc """
  Resume a suspended process instance.
  """
  @spec resume(pid()) :: :ok | {:error, any()}
  def resume(pid) do
    GenServer.call(pid, :resume)
  end

  @doc """
  Terminate a process instance and stop its context.
  """
  @spec terminate(pid()) :: :ok
  def terminate(pid) do
    GenServer.call(pid, :terminate)
  end

  @doc """
  Query the current status of a process instance.
  """
  @spec status(pid()) :: status()
  def status(pid) do
    GenServer.call(pid, :status)
  end

  @doc """
  Get the context pid for a process instance.
  """
  @spec get_context(pid()) :: pid()
  def get_context(pid) do
    GenServer.call(pid, :get_context)
  end

  @doc """
  Get the instance ID of a process instance.
  """
  @spec instance_id(pid()) :: String.t()
  def instance_id(pid) do
    GenServer.call(pid, :instance_id)
  end

  # --- GenServer Callbacks ---

  @impl true
  def init({process_id, init_data}) do
    case Bpmn.Registry.lookup(process_id) do
      {:ok, {_type, attrs, elements}} ->
        process_map = build_process_map(elements)

        case Bpmn.Context.start_supervised(process_map, init_data) do
          {:ok, context} ->
            {:ok,
             %{
               instance_id: generate_instance_id(),
               process_id: process_id,
               definition: {attrs, elements},
               context: context,
               status: :created,
               root_token: nil
             }}

          error ->
            {:stop, error}
        end

      :error ->
        {:stop, {:error, "Process '#{process_id}' not found in registry"}}
    end
  end

  @impl true
  def handle_call(:activate, _from, %{status: :created} = state) do
    process_map = Bpmn.Context.get(state.context, :process)

    case find_start_event(process_map) do
      nil ->
        state = %{state | status: :error}
        {:reply, {:error, "No start event found"}, state}

      start_event ->
        token = Bpmn.Token.new()
        state = %{state | status: :running, root_token: token}

        result = Bpmn.execute(start_event, state.context, token)

        state =
          case result do
            {:ok, _} -> %{state | status: :completed}
            {:error, _} -> %{state | status: :error}
            {:manual, _} -> %{state | status: :suspended}
            _ -> %{state | status: :error}
          end

        {:reply, :ok, state}
    end
  end

  def handle_call(:activate, _from, state) do
    {:reply, {:error, "Cannot activate process in status: #{state.status}"}, state}
  end

  def handle_call(:suspend, _from, %{status: :running} = state) do
    {:reply, :ok, %{state | status: :suspended}}
  end

  def handle_call(:suspend, _from, state) do
    {:reply, {:error, "Cannot suspend process in status: #{state.status}"}, state}
  end

  def handle_call(:resume, _from, %{status: :suspended} = state) do
    {:reply, :ok, %{state | status: :running}}
  end

  def handle_call(:resume, _from, state) do
    {:reply, {:error, "Cannot resume process in status: #{state.status}"}, state}
  end

  def handle_call(:terminate, _from, state) do
    if Process.alive?(state.context) do
      GenServer.stop(state.context, :normal)
    end

    {:reply, :ok, %{state | status: :terminated}}
  end

  def handle_call(:status, _from, state) do
    {:reply, state.status, state}
  end

  def handle_call(:get_context, _from, state) do
    {:reply, state.context, state}
  end

  def handle_call(:instance_id, _from, state) do
    {:reply, state.instance_id, state}
  end

  # --- Private helpers ---

  defp find_start_event(process_map) do
    Enum.find_value(process_map, fn
      {_id, {:bpmn_event_start, _} = elem} -> elem
      _ -> nil
    end)
  end

  defp build_process_map(elements) when is_map(elements), do: elements

  defp build_process_map(elements) when is_list(elements) do
    Enum.reduce(elements, %{}, fn
      {_type, %{id: id}} = elem, acc -> Map.put(acc, id, elem)
      _, acc -> acc
    end)
  end

  defp generate_instance_id do
    Bpmn.Token.new().id
  end
end
