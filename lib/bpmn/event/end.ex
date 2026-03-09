defmodule Bpmn.Event.End do
  @moduledoc """
  Handle passing the token through an end event element.

    iex> {:ok, context} = Bpmn.Context.start_link(%{}, %{})
    iex> {:ok, ^context} = Bpmn.Event.End.token_in({:bpmn_event_end, %{incoming: []}}, context)
    iex> true
    true

  """

  @doc """
  Receive the token for the element and decide if the business logic should be executed
  """
  @spec token_in(Bpmn.element(), Bpmn.context()) :: Bpmn.result()
  def token_in(_elem, context), do: {:ok, context}
end
