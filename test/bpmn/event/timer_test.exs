defmodule Bpmn.Event.TimerTest do
  use ExUnit.Case, async: true

  describe "parse_duration/1" do
    test "parses seconds" do
      assert Bpmn.Event.Timer.parse_duration("PT5S") == {:ok, 5_000}
      assert Bpmn.Event.Timer.parse_duration("PT30S") == {:ok, 30_000}
    end

    test "parses minutes" do
      assert Bpmn.Event.Timer.parse_duration("PT1M") == {:ok, 60_000}
      assert Bpmn.Event.Timer.parse_duration("PT15M") == {:ok, 900_000}
    end

    test "parses hours" do
      assert Bpmn.Event.Timer.parse_duration("PT1H") == {:ok, 3_600_000}
      assert Bpmn.Event.Timer.parse_duration("PT2H") == {:ok, 7_200_000}
    end

    test "parses combined duration" do
      assert Bpmn.Event.Timer.parse_duration("PT1H30M") == {:ok, 5_400_000}
      assert Bpmn.Event.Timer.parse_duration("PT1M30S") == {:ok, 90_000}
      assert Bpmn.Event.Timer.parse_duration("PT2H15M30S") == {:ok, 8_130_000}
    end

    test "returns error for invalid format" do
      assert {:error, _} = Bpmn.Event.Timer.parse_duration("invalid")
      assert {:error, _} = Bpmn.Event.Timer.parse_duration("P1D")
      assert {:error, _} = Bpmn.Event.Timer.parse_duration("")
      assert {:error, _} = Bpmn.Event.Timer.parse_duration("PT")
    end
  end

  describe "schedule/4 and cancel/1" do
    test "schedules a timer and receives the message" do
      {:ok, context} = Bpmn.Context.start_link(%{}, %{})
      timer_ref = Bpmn.Event.Timer.schedule(10, self(), "node1", ["flow_out"])

      assert is_reference(timer_ref)
      assert_receive {:timer_fired, "node1", ["flow_out"]}, 100
    end

    test "cancel prevents the timer from firing" do
      timer_ref = Bpmn.Event.Timer.schedule(50, self(), "node1", ["flow_out"])
      Bpmn.Event.Timer.cancel(timer_ref)

      refute_receive {:timer_fired, _, _}, 100
    end
  end
end
