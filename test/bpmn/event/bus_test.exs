defmodule Bpmn.Event.BusTest do
  use ExUnit.Case, async: true

  describe "subscribe/3 and unsubscribe/2" do
    test "subscribes and returns event key" do
      {:ok, key} = Bpmn.Event.Bus.subscribe(:message, "test_sub_#{:erlang.unique_integer()}")
      assert {type, _name} = key
      assert type == :message
    end

    test "unsubscribe removes subscription" do
      name = "test_unsub_#{:erlang.unique_integer()}"
      Bpmn.Event.Bus.subscribe(:message, name, %{node_id: "n1"})
      assert length(Bpmn.Event.Bus.subscriptions(:message, name)) == 1

      Bpmn.Event.Bus.unsubscribe(:message, name)
      assert Bpmn.Event.Bus.subscriptions(:message, name) == []
    end
  end

  describe "publish/3 with :message type" do
    test "delivers to first subscriber and unregisters it" do
      name = "msg_#{:erlang.unique_integer()}"
      Bpmn.Event.Bus.subscribe(:message, name, %{node_id: "n1"})

      assert :ok = Bpmn.Event.Bus.publish(:message, name, %{data: "hello"})
      assert_receive {:bpmn_event, :message, ^name, %{data: "hello"}, %{node_id: "n1"}}

      # Subscriber should be removed after delivery
      assert Bpmn.Event.Bus.subscriptions(:message, name) == []
    end

    test "returns error when no subscriber exists" do
      assert {:error, :no_subscriber} =
               Bpmn.Event.Bus.publish(:message, "no_such_#{:erlang.unique_integer()}", %{})
    end
  end

  describe "publish/3 with :signal type" do
    test "broadcasts to all subscribers" do
      name = "sig_#{:erlang.unique_integer()}"
      Bpmn.Event.Bus.subscribe(:signal, name, %{node_id: "n1"})

      # Spawn another subscriber
      parent = self()

      spawn(fn ->
        Bpmn.Event.Bus.subscribe(:signal, name, %{node_id: "n2"})
        send(parent, :subscribed)

        receive do
          msg -> send(parent, {:child_received, msg})
        end
      end)

      receive do
        :subscribed -> :ok
      end

      assert :ok = Bpmn.Event.Bus.publish(:signal, name, %{data: "broadcast"})
      assert_receive {:bpmn_event, :signal, ^name, %{data: "broadcast"}, %{node_id: "n1"}}
      assert_receive {:child_received, {:bpmn_event, :signal, ^name, _, %{node_id: "n2"}}}
    end

    test "returns ok even with no subscribers" do
      assert :ok = Bpmn.Event.Bus.publish(:signal, "no_such_#{:erlang.unique_integer()}", %{})
    end
  end

  describe "publish/3 with :escalation type" do
    test "broadcasts to all subscribers" do
      name = "esc_#{:erlang.unique_integer()}"
      Bpmn.Event.Bus.subscribe(:escalation, name, %{node_id: "n1"})

      assert :ok = Bpmn.Event.Bus.publish(:escalation, name, %{code: "E1"})
      assert_receive {:bpmn_event, :escalation, ^name, %{code: "E1"}, %{node_id: "n1"}}
    end
  end

  describe "subscriptions/2" do
    test "lists current subscribers" do
      name = "list_#{:erlang.unique_integer()}"
      Bpmn.Event.Bus.subscribe(:message, name, %{node_id: "n1"})

      subs = Bpmn.Event.Bus.subscriptions(:message, name)
      assert length(subs) == 1
      assert hd(subs).node_id == "n1"
    end

    test "returns empty list for no subscribers" do
      assert Bpmn.Event.Bus.subscriptions(:message, "empty_#{:erlang.unique_integer()}") == []
    end
  end
end
