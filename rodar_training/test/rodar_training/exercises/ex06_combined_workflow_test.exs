defmodule RodarTraining.Exercises.Ex06CombinedWorkflowTest do
  use ExUnit.Case

  # Change this to your exercise module to test your solution:
  # @module RodarTraining.Exercises.Ex06CombinedWorkflow
  @module RodarTraining.Solutions.Ex06CombinedWorkflow

  describe "PrepareRequest" do
    test "sets prepared flag and builds summary" do
      {:ok, result} =
        @module.PrepareRequest.execute(%{}, %{"requester" => "alice", "amount" => 500})

      assert result["prepared"] == true
      assert result["request_summary"] == "alice requests $500"
    end
  end

  describe "run/1 and approve/1" do
    test "approval path leads to fulfilled status" do
      data = %{"requester" => "alice", "amount" => 500}
      {:ok, pid} = @module.run(data)
      assert :suspended == Rodar.Process.status(pid)

      # Verify prepare handler ran
      context = Rodar.Process.get_context(pid)
      assert Rodar.Context.get_data(context, "prepared") == true

      # Approve
      @module.approve(pid)

      assert Rodar.Context.get_data(context, "status") == "fulfilled"
    end
  end

  describe "run/1 and reject/1" do
    test "rejection path leads to rejected status" do
      data = %{"requester" => "bob", "amount" => 200}
      {:ok, pid} = @module.run(data)
      assert :suspended == Rodar.Process.status(pid)

      # Reject
      @module.reject(pid)

      context = Rodar.Process.get_context(pid)
      assert Rodar.Context.get_data(context, "status") == "rejected"
    end
  end
end
