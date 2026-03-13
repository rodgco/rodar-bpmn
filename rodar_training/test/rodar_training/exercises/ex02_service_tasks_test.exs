defmodule RodarTraining.Exercises.Ex02ServiceTasksTest do
  use ExUnit.Case

  # Change this to your exercise module to test your solution:
  # @module RodarTraining.Exercises.Ex02ServiceTasks
  @module RodarTraining.Solutions.Ex02ServiceTasks

  describe "ValidateOrder" do
    test "returns valid when item exists and quantity > 0" do
      assert {:ok, %{"valid" => true}} =
               @module.ValidateOrder.execute(%{}, %{"item" => "Widget", "quantity" => 3})
    end

    test "returns invalid when item is missing" do
      assert {:ok, %{"valid" => false}} =
               @module.ValidateOrder.execute(%{}, %{"quantity" => 3})
    end

    test "returns invalid when quantity is 0" do
      assert {:ok, %{"valid" => false}} =
               @module.ValidateOrder.execute(%{}, %{"item" => "Widget", "quantity" => 0})
    end
  end

  describe "CalculateTotal" do
    test "multiplies quantity by price" do
      assert {:ok, %{"total" => 75}} =
               @module.CalculateTotal.execute(%{}, %{"quantity" => 3, "price" => 25})
    end

    test "handles missing values as 0" do
      assert {:ok, %{"total" => 0}} =
               @module.CalculateTotal.execute(%{}, %{})
    end
  end

  describe "run/1" do
    test "runs the order validation process end to end" do
      data = %{"item" => "Widget", "quantity" => 3, "price" => 25}
      assert {:ok, pid} = @module.run(data)
      assert :completed == Rodar.Process.status(pid)

      context = Rodar.Process.get_context(pid)
      assert Rodar.Context.get_data(context, "valid") == true
      assert Rodar.Context.get_data(context, "total") == 75
    end
  end
end
