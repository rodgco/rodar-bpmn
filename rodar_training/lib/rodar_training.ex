defmodule RodarTraining do
  @moduledoc """
  Rodar Training — A hands-on tutorial for the Rodar BPMN engine.

  This project walks you through building BPMN-powered workflows
  in Elixir, from your first "hello world" process to a complete
  order management system.

  ## How to use this training

  1. Read the guides in order (guides/01_introduction.md through 10)
  2. Each guide has a companion exercise in lib/rodar_training/exercises/
  3. Fill in the exercise stubs, then run the matching test to verify
  4. If you get stuck, check the solutions in lib/rodar_training/solutions/

  ## Running exercises

      # Run all exercise tests
      mix test

      # Run a specific exercise test
      mix test test/rodar_training/exercises/ex01_first_process_test.exs

  ## Guides

  1. Introduction to BPMN & Rodar
  2. Your First Process
  3. Service Tasks
  4. User Tasks & Resuming
  5. Exclusive Gateways
  6. Parallel Gateways
  7. Expressions (FEEL & Elixir)
  8. Events (Timer, Message, Signal)
  9. The Workflow API
  10. Building a Domain API with Workflow.Server
  """
end
