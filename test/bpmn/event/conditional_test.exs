defmodule Bpmn.Event.ConditionalTest do
  use ExUnit.Case, async: true

  defp make_process do
    end_event = {:bpmn_event_end, %{id: "end", incoming: ["flow"], outgoing: []}}

    flow =
      {:bpmn_sequence_flow,
       %{
         id: "flow",
         sourceRef: "catch1",
         targetRef: "end",
         conditionExpression: nil,
         isImmediate: nil
       }}

    %{"flow" => flow, "end" => end_event}
  end

  describe "conditional catch event" do
    test "fires immediately when condition is already true" do
      {:ok, context} = Bpmn.Context.start_link(make_process(), %{})
      Bpmn.Context.put_data(context, "approved", true)

      elem =
        {:bpmn_event_intermediate_catch,
         %{
           id: "catch1",
           outgoing: ["flow"],
           messageEventDefinition: nil,
           signalEventDefinition: nil,
           timerEventDefinition: nil,
           conditionalEventDefinition:
             {:bpmn_event_definition_conditional,
              %{condition: ~S|data["approved"] == true|, _elems: []}}
         }}

      assert {:ok, ^context} = Bpmn.Event.Intermediate.Catch.token_in(elem, context)
    end

    test "returns manual when condition is false" do
      {:ok, context} = Bpmn.Context.start_link(make_process(), %{})

      elem =
        {:bpmn_event_intermediate_catch,
         %{
           id: "catch1",
           outgoing: ["flow"],
           messageEventDefinition: nil,
           signalEventDefinition: nil,
           timerEventDefinition: nil,
           conditionalEventDefinition:
             {:bpmn_event_definition_conditional,
              %{condition: ~S|data["approved"] == true|, _elems: []}}
         }}

      assert {:manual, task_data} = Bpmn.Event.Intermediate.Catch.token_in(elem, context)
      assert task_data.id == "catch1"
      assert task_data.type == :conditional_catch
      assert task_data.condition == ~S|data["approved"] == true|
    end

    test "fires when data changes make condition true" do
      {:ok, context} = Bpmn.Context.start_link(make_process(), %{})

      elem =
        {:bpmn_event_intermediate_catch,
         %{
           id: "catch1",
           outgoing: ["flow"],
           messageEventDefinition: nil,
           signalEventDefinition: nil,
           timerEventDefinition: nil,
           conditionalEventDefinition:
             {:bpmn_event_definition_conditional,
              %{condition: ~S|data["approved"] == true|, _elems: []}}
         }}

      assert {:manual, _} = Bpmn.Event.Intermediate.Catch.token_in(elem, context)

      # Condition is false, node should be active
      meta = Bpmn.Context.get_meta(context, "catch1")
      assert meta.active == true
      assert meta.completed == false

      # Change data to make condition true
      Bpmn.Context.put_data(context, "approved", true)

      # Allow the spawned process to complete
      Process.sleep(50)

      # Node should now be completed
      meta = Bpmn.Context.get_meta(context, "catch1")
      assert meta.active == false
      assert meta.completed == true
    end

    test "returns error when no condition expression" do
      {:ok, context} = Bpmn.Context.start_link(make_process(), %{})

      elem =
        {:bpmn_event_intermediate_catch,
         %{
           id: "catch1",
           outgoing: ["flow"],
           messageEventDefinition: nil,
           signalEventDefinition: nil,
           timerEventDefinition: nil,
           conditionalEventDefinition:
             {:bpmn_event_definition_conditional, %{condition: nil, _elems: []}}
         }}

      assert {:error, msg} = Bpmn.Event.Intermediate.Catch.token_in(elem, context)
      assert msg =~ "no condition expression"
    end

    test "condition expression uses sandbox safely" do
      {:ok, context} = Bpmn.Context.start_link(make_process(), %{})
      Bpmn.Context.put_data(context, "count", 10)

      elem =
        {:bpmn_event_intermediate_catch,
         %{
           id: "catch1",
           outgoing: ["flow"],
           messageEventDefinition: nil,
           signalEventDefinition: nil,
           timerEventDefinition: nil,
           conditionalEventDefinition:
             {:bpmn_event_definition_conditional, %{condition: ~S|data["count"] > 5|, _elems: []}}
         }}

      assert {:ok, ^context} = Bpmn.Event.Intermediate.Catch.token_in(elem, context)
    end
  end

  describe "conditional boundary event" do
    test "subscribes and returns manual when condition is false" do
      process = make_process()
      {:ok, context} = Bpmn.Context.start_link(process, %{})

      elem =
        {:bpmn_event_boundary,
         %{
           id: "b1",
           outgoing: ["flow"],
           attachedToRef: "task1",
           errorEventDefinition: nil,
           messageEventDefinition: nil,
           signalEventDefinition: nil,
           timerEventDefinition: nil,
           escalationEventDefinition: nil,
           compensateEventDefinition: nil,
           conditionalEventDefinition:
             {:bpmn_event_definition_conditional,
              %{condition: ~S|data["ready"] == true|, _elems: []}}
         }}

      assert {:manual, task_data} = Bpmn.Event.Boundary.token_in(elem, context)
      assert task_data.id == "b1"
      assert task_data.type == :conditional_boundary
    end

    test "fires when data changes make condition true" do
      process = make_process()
      {:ok, context} = Bpmn.Context.start_link(process, %{})

      elem =
        {:bpmn_event_boundary,
         %{
           id: "b1",
           outgoing: ["flow"],
           attachedToRef: "task1",
           errorEventDefinition: nil,
           messageEventDefinition: nil,
           signalEventDefinition: nil,
           timerEventDefinition: nil,
           escalationEventDefinition: nil,
           compensateEventDefinition: nil,
           conditionalEventDefinition:
             {:bpmn_event_definition_conditional,
              %{condition: ~S|data["ready"] == true|, _elems: []}}
         }}

      assert {:manual, _} = Bpmn.Event.Boundary.token_in(elem, context)

      # Change data to trigger condition
      Bpmn.Context.put_data(context, "ready", true)

      # Allow the spawned process to complete
      Process.sleep(50)

      # Node should be completed
      meta = Bpmn.Context.get_meta(context, "b1")
      assert meta.active == false
      assert meta.completed == true
    end

    test "returns error when no condition expression" do
      process = make_process()
      {:ok, context} = Bpmn.Context.start_link(process, %{})

      elem =
        {:bpmn_event_boundary,
         %{
           id: "b1",
           outgoing: ["flow"],
           attachedToRef: "task1",
           errorEventDefinition: nil,
           messageEventDefinition: nil,
           signalEventDefinition: nil,
           timerEventDefinition: nil,
           escalationEventDefinition: nil,
           compensateEventDefinition: nil,
           conditionalEventDefinition:
             {:bpmn_event_definition_conditional, %{condition: nil, _elems: []}}
         }}

      assert {:error, msg} = Bpmn.Event.Boundary.token_in(elem, context)
      assert msg =~ "no condition expression"
    end
  end

  describe "context conditional subscriptions" do
    test "subscribe and unsubscribe" do
      {:ok, context} = Bpmn.Context.start_link(%{}, %{})

      :ok =
        Bpmn.Context.subscribe_condition(context, "sub1", ~S|data["x"] == 1|, %{
          outgoing: ["flow"]
        })

      state = Bpmn.Context.get_state(context)
      assert Map.has_key?(state.conditional_subscriptions, "sub1")

      :ok = Bpmn.Context.unsubscribe_condition(context, "sub1")
      state = Bpmn.Context.get_state(context)
      refute Map.has_key?(state.conditional_subscriptions, "sub1")
    end

    test "condition not re-triggered after firing" do
      {:ok, context} = Bpmn.Context.start_link(make_process(), %{})

      :ok =
        Bpmn.Context.subscribe_condition(context, "catch1", ~S|data["x"] == true|, %{
          outgoing: ["flow"]
        })

      # Trigger the condition
      Bpmn.Context.put_data(context, "x", true)
      Process.sleep(50)

      # Subscription should be removed after firing
      state = Bpmn.Context.get_state(context)
      refute Map.has_key?(state.conditional_subscriptions, "catch1")
    end
  end
end
