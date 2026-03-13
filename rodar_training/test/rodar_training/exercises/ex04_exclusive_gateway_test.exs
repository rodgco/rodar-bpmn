defmodule RodarTraining.Exercises.Ex04ExclusiveGatewayTest do
  use ExUnit.Case

  # Change this to your exercise module to test your solution:
  # @module RodarTraining.Exercises.Ex04ExclusiveGateway
  @module RodarTraining.Solutions.Ex04ExclusiveGateway

  describe "ClassifyOrder" do
    test "classifies high-value orders as express" do
      assert {:ok, %{"order_type" => "express"}} =
               @module.ClassifyOrder.execute(%{}, %{"total" => 500})
    end

    test "classifies low-value orders as standard" do
      assert {:ok, %{"order_type" => "standard"}} =
               @module.ClassifyOrder.execute(%{}, %{"total" => 100})
    end
  end

  describe "run/1" do
    test "routes express orders to express processing" do
      {:ok, pid} = @module.run(%{"total" => 1000})
      assert :completed == Rodar.Process.status(pid)

      context = Rodar.Process.get_context(pid)
      assert Rodar.Context.get_data(context, "order_type") == "express"
      assert Rodar.Context.get_data(context, "processing") == "express"
    end

    test "routes standard orders to standard processing" do
      {:ok, pid} = @module.run(%{"total" => 50})
      assert :completed == Rodar.Process.status(pid)

      context = Rodar.Process.get_context(pid)
      assert Rodar.Context.get_data(context, "order_type") == "standard"
      assert Rodar.Context.get_data(context, "processing") == "standard"
    end
  end
end
