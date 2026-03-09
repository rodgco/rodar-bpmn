defmodule Bpmn.Activity.Task.Script do
  @moduledoc """
  Handle passing the token through a script task element.

    iex> Bpmn.Port.Nodejs.eval_string("1+1", %{cosmin: "soss"})
    %{"context" => %{"cosmin" => "soss"}, "script" => "1+1", "type" => "string"}

  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  @spec token_in(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def token_in(elem, context), do: execute(elem, context)

  defp token_out(_elem, _context), do: {:not_implemented}

  @doc """
  Execute the script task business logic
  """
  @spec execute(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def execute(
        {:bpmn_activity_task_script, %{outputs: _outputs, type: _type, script: _script}},
        _context
      ) do
    IO.inspect(Bpmn.Port.Nodejs.eval_string("1+3", %{testing: "something"}))
  end

  def execute(elem, context), do: token_out(elem, context)
end
