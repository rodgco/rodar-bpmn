defmodule RodarTraining.Exercises.Ex05ParallelGatewayTest do
  use ExUnit.Case

  # Change this to your exercise module to test your solution:
  # @module RodarTraining.Exercises.Ex05ParallelGateway
  @module RodarTraining.Solutions.Ex05ParallelGateway

  describe "GenerateInvoice" do
    test "builds invoice number from order_id" do
      assert {:ok, %{"invoice_number" => "INV-ORD-001"}} =
               @module.GenerateInvoice.execute(%{}, %{"order_id" => "ORD-001"})
    end
  end

  describe "run/1" do
    test "runs packing, invoicing, and shipping" do
      data = %{"order_id" => "ORD-001", "items" => ["Widget A", "Widget B"]}
      {:ok, pid} = @module.run(data)
      assert :completed == Rodar.Process.status(pid)

      context = Rodar.Process.get_context(pid)
      assert Rodar.Context.get_data(context, "packed") == true
      assert Rodar.Context.get_data(context, "invoice_number") == "INV-ORD-001"
      assert Rodar.Context.get_data(context, "shipped") == true
    end
  end
end
