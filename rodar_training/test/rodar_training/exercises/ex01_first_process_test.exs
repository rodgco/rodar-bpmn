defmodule RodarTraining.Exercises.Ex01FirstProcessTest do
  use ExUnit.Case

  # Change this to your exercise module to test your solution:
  # @module RodarTraining.Exercises.Ex01FirstProcess
  @module RodarTraining.Solutions.Ex01FirstProcess

  describe "run/0" do
    test "loads, registers, and runs the hello world process" do
      assert {:ok, status} = @module.run()
      assert status == :completed
    end
  end
end
