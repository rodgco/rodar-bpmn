defmodule RodarBpmn.Expression.ScriptEngine do
  @moduledoc """
  Behaviour for pluggable script language engines.

  Implement this behaviour to register custom script languages for use
  in BPMN script tasks. The engine receives the script text and a map
  of bindings (the current process data) and returns a result.

  ## Example

      defmodule MyApp.LuaEngine do
        @behaviour RodarBpmn.Expression.ScriptEngine

        @impl true
        def eval(script, bindings) do
          case Lua.eval(script, bindings) do
            {:ok, result} -> {:ok, result}
            {:error, reason} -> {:error, reason}
          end
        end
      end

      # Register the engine for a language string
      RodarBpmn.Expression.ScriptRegistry.register("lua", MyApp.LuaEngine)

  Once registered, any script task with `type: "lua"` will be routed
  to `MyApp.LuaEngine.eval/2`.
  """

  @callback eval(script :: String.t(), bindings :: map()) :: {:ok, any()} | {:error, any()}
end
