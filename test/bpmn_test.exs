defmodule BpmnTest do
  use ExUnit.Case
  doctest Bpmn
  doctest Bpmn.Activity.Subprocess
  doctest Bpmn.Event.Boundary
  doctest Bpmn.Event.Intermediate
  doctest Bpmn.Event.Intermediate.Throw
  doctest Bpmn.Event.Intermediate.Catch
  doctest Bpmn.Event.Bus
  doctest Bpmn.Event.Timer
  doctest Bpmn.Gateway.Exclusive.Event
  doctest Bpmn.Gateway.Complex
end
