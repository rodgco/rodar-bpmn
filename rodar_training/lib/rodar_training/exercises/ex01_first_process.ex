defmodule RodarTraining.Exercises.Ex01FirstProcess do
  @moduledoc """
  Exercise 1: Your First Process

  Load and run the simplest BPMN process — a start event connected to an end event.

  ## Instructions

  Implement the `run/0` function to:
  1. Read the `01_hello_world.bpmn` file from `priv/bpmn/`
  2. Parse it with `Rodar.Engine.Diagram.load/1`
  3. Register the process as `"hello-world"`
  4. Create and run an instance with empty data
  5. Return `{:ok, status}` where `status` is the process status

  ## Hints

  - Use `File.read!/1` to read the BPMN file
  - Use `Application.app_dir(:rodar_training, "priv/bpmn/01_hello_world.bpmn")` for the path
  - `Rodar.Engine.Diagram.load/1` returns a map with a `:processes` key
  - `Rodar.Registry.register/2` takes an ID string and a process tuple
  - `Rodar.Process.create_and_run/2` takes the registered ID and a data map
  - `Rodar.Process.status/1` returns the current status atom
  """

  @doc """
  Loads the hello world BPMN, registers it, runs it, and returns the status.

  Returns `{:ok, :completed}` on success.
  """
  @spec run() :: {:ok, atom()}
  def run do
    # TODO: Implement this function
    # Step 1: Read the BPMN file
    # Step 2: Parse with Rodar.Engine.Diagram.load/1
    # Step 3: Extract the first process from diagram.processes
    # Step 4: Register as "hello-world"
    # Step 5: Create and run with empty data
    # Step 6: Return {:ok, status}
    raise "Not implemented yet — see the instructions in the @moduledoc"
  end
end
