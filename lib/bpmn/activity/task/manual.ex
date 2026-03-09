defmodule Bpmn.Activity.Task.Manual do
  @moduledoc """
  Handle passing the token through a manual task element.

    iex> Bpmn.Activity.Task.Manual.token_in(%{}, nil)
    {:not_implemented}

  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  @spec token_in(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def token_in(elem, context), do: execute(elem, context)

  defp token_out(_elem, _context), do: {:not_implemented}

  @doc """
  Execute the manual task business logic
  """
  @spec execute(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def execute(elem, context), do: token_out(elem, context)
end
