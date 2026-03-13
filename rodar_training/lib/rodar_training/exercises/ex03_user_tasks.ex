defmodule RodarTraining.Exercises.Ex03UserTasks do
  @moduledoc """
  Exercise 3: User Tasks & Resuming

  Start a process with a user task, then resume it with input data.

  ## Instructions

  1. Implement `start/0`:
     - Load `03_approval_flow.bpmn`
     - Register as `"approval-flow"`
     - Run with `%{"requester" => "alice", "amount" => 500}`
     - Return `{:ok, pid}`

  2. Implement `approve/1`:
     - Given a process pid, resume the `"Task_Review"` user task
     - Pass `%{"approved" => true}` as the input
     - Return the result of `Rodar.Activity.Task.User.resume/3`

  ## Hints

  - To resume, you need the task element from the process map:
    ```
    context = Rodar.Process.get_context(pid)
    process_map = Rodar.Context.get(context, :process)
    task_element = Map.get(process_map, "Task_Review")
    ```
  - Then call `Rodar.Activity.Task.User.resume(task_element, context, input)`
  """

  @spec start() :: {:ok, pid()}
  def start do
    # TODO: Load BPMN, register, run with sample data
    raise "Not implemented yet"
  end

  @spec approve(pid()) :: {:ok, any()} | {:manual, any()}
  def approve(_pid) do
    # TODO: Resume the user task with approval data
    raise "Not implemented yet"
  end
end
