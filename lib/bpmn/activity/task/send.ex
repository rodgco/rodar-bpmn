defmodule Bpmn.Activity.Task.Send do
  @moduledoc """
  Handle passing the token through a send task element.

    iex> Bpmn.Activity.Task.Send.token_in(%{}, nil)
    {:not_implemented}

  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  @spec token_in(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def token_in(elem, context), do: execute(elem, context)
  defp token_out(_elem, _context), do: {:not_implemented}

  @doc """
  Execute the send task business logic
  """
  @spec execute(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def execute(elem, context), do: token_out(elem, context)
end
