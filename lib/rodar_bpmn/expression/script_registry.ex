defmodule RodarBpmn.Expression.ScriptRegistry do
  @moduledoc """
  Registry for custom script language engines.

  Maps language strings (e.g., `"lua"`, `"python"`) to engine modules
  implementing the `RodarBpmn.Expression.ScriptEngine` behaviour. Used by
  `RodarBpmn.Activity.Task.Script` to resolve script languages beyond the
  built-in `"elixir"` and `"feel"` engines.

  ## Examples

      iex> RodarBpmn.Expression.ScriptRegistry.register("lua", MyLuaEngine)
      :ok
      iex> {:ok, MyLuaEngine} = RodarBpmn.Expression.ScriptRegistry.lookup("lua")
      iex> RodarBpmn.Expression.ScriptRegistry.unregister("lua")
      :ok

  """

  use GenServer

  # --- Client API ---

  @doc "Start the script registry GenServer."
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  @doc """
  Register an engine module for a script language string.
  """
  @spec register(String.t(), module()) :: :ok
  def register(language, engine_module) do
    GenServer.call(__MODULE__, {:register, language, engine_module})
  end

  @doc """
  Remove an engine registration.
  """
  @spec unregister(String.t()) :: :ok
  def unregister(language) do
    GenServer.call(__MODULE__, {:unregister, language})
  end

  @doc """
  Look up an engine by language string.

  Returns `{:ok, module}` or `:error`.
  """
  @spec lookup(String.t()) :: {:ok, module()} | :error
  def lookup(language) do
    GenServer.call(__MODULE__, {:lookup, language})
  end

  @doc """
  List all registered engines.

  Returns a list of `{language, module}` tuples.
  """
  @spec list() :: [{String.t(), module()}]
  def list do
    GenServer.call(__MODULE__, :list)
  end

  # --- GenServer Callbacks ---

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:register, language, engine_module}, _from, state) do
    {:reply, :ok, Map.put(state, language, engine_module)}
  end

  def handle_call({:unregister, language}, _from, state) do
    {:reply, :ok, Map.delete(state, language)}
  end

  def handle_call({:lookup, language}, _from, state) do
    case Map.fetch(state, language) do
      {:ok, module} -> {:reply, {:ok, module}, state}
      :error -> {:reply, :error, state}
    end
  end

  def handle_call(:list, _from, state) do
    {:reply, Enum.into(state, []), state}
  end
end
