defmodule RodarTraining.Exercises.Ex03UserTasksTest do
  use ExUnit.Case

  # Change this to your exercise module to test your solution:
  # @module RodarTraining.Exercises.Ex03UserTasks
  @module RodarTraining.Solutions.Ex03UserTasks

  describe "start/0" do
    test "starts a process that suspends at the user task" do
      assert {:ok, pid} = @module.start()
      assert :suspended == Rodar.Process.status(pid)
    end

    test "sets the initial data" do
      {:ok, pid} = @module.start()
      context = Rodar.Process.get_context(pid)
      assert Rodar.Context.get_data(context, "requester") == "alice"
      assert Rodar.Context.get_data(context, "amount") == 500
    end
  end

  describe "approve/1" do
    test "resumes the user task and completes the process" do
      {:ok, pid} = @module.start()
      assert :suspended == Rodar.Process.status(pid)

      @module.approve(pid)

      context = Rodar.Process.get_context(pid)
      assert Rodar.Context.get_data(context, "approved") == true
    end
  end
end
