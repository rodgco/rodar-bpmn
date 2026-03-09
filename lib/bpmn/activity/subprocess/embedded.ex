defmodule Bpmn.Activity.Subprocess.Embedded do
  @moduledoc """
  Handle passing the token through an embedded subprocess element.

    iex> Bpmn.Activity.Subprocess.Embedded.token_in(%{}, nil)
    {:not_implemented}

  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  @spec token_in(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def token_in(elem, context), do: execute(elem, context)
  defp token_out(_elem, _context), do: {:not_implemented}

  @doc """
  Execute the embedded subprocess business logic
  """
  @spec execute(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def execute(elem, context), do: token_out(elem, context)
end
