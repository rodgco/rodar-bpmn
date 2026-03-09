defmodule Bpmn.Event.Timer do
  @moduledoc """
  Timer parsing and scheduling utilities for BPMN timer events.

  Parses ISO 8601 duration strings and schedules callbacks using
  `Process.send_after/3`.

  ## Examples

      iex> Bpmn.Event.Timer.parse_duration("PT5S")
      {:ok, 5_000}

      iex> Bpmn.Event.Timer.parse_duration("PT1H")
      {:ok, 3_600_000}

      iex> Bpmn.Event.Timer.parse_duration("PT1M30S")
      {:ok, 90_000}

      iex> Bpmn.Event.Timer.parse_duration("invalid")
      {:error, "invalid ISO 8601 duration: \\"invalid\\""}

  """

  @doc """
  Parse an ISO 8601 duration string into milliseconds.

  Supports the `PT` (period time) format with hours (H), minutes (M),
  and seconds (S) components.
  """
  @spec parse_duration(String.t()) :: {:ok, non_neg_integer()} | {:error, String.t()}
  def parse_duration(iso_string) do
    case Regex.named_captures(
           ~r/^PT(?:(?<hours>\d+)H)?(?:(?<minutes>\d+)M)?(?:(?<seconds>\d+)S)?$/,
           iso_string
         ) do
      nil ->
        {:error, "invalid ISO 8601 duration: #{inspect(iso_string)}"}

      %{"hours" => h, "minutes" => m, "seconds" => s} ->
        hours = parse_int(h)
        minutes = parse_int(m)
        seconds = parse_int(s)

        if hours == 0 and minutes == 0 and seconds == 0 do
          {:error, "invalid ISO 8601 duration: #{inspect(iso_string)}"}
        else
          {:ok, (hours * 3600 + minutes * 60 + seconds) * 1000}
        end
    end
  end

  @doc """
  Schedule a timer that sends `{:timer_fired, node_id, outgoing}` to the
  context process after `duration_ms` milliseconds.

  Returns the timer reference which can be used to cancel.
  """
  @spec schedule(non_neg_integer(), pid(), String.t(), [String.t()]) :: reference()
  def schedule(duration_ms, context, node_id, outgoing) do
    Process.send_after(context, {:timer_fired, node_id, outgoing}, duration_ms)
  end

  @doc """
  Cancel a scheduled timer.
  """
  @spec cancel(reference()) :: :ok
  def cancel(timer_ref) do
    Process.cancel_timer(timer_ref)
    :ok
  end

  defp parse_int(""), do: 0
  defp parse_int(s), do: String.to_integer(s)
end
