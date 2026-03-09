defmodule Bpmn.Event.Intermediate do
  @moduledoc """
  Handle passing the token through an intermediate event element.

  This module is kept for backward compatibility with the legacy
  `:bpmn_event_intermediate` tag. New code should use
  `Bpmn.Event.Intermediate.Throw` and `Bpmn.Event.Intermediate.Catch`.

    iex> Bpmn.Event.Intermediate.token_in({:bpmn_event_intermediate, %{}}, nil)
    {:not_implemented}

  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  @spec token_in(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def token_in(_elem, _context), do: {:not_implemented}
end
