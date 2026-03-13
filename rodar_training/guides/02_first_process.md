# Chapter 2: Your First Process

In this chapter, you'll parse a BPMN XML file, register a process definition,
create a running instance, and check its status.

## The Hello World Diagram

Open `priv/bpmn/01_hello_world.bpmn`. It's the simplest BPMN diagram possible:

```
[Start] --> [End]
```

A start event, a sequence flow, and an end event. When executed, a token enters
at `Start_1`, flows to `End_1`, and the process completes.

## Step-by-Step Execution

### 1. Parse the BPMN XML

```elixir
xml = File.read!("priv/bpmn/01_hello_world.bpmn")
diagram = Rodar.Engine.Diagram.load(xml)
```

`Diagram.load/1` returns a map with a `:processes` key containing a list of
parsed process tuples. Each process is a 3-tuple:

```elixir
{:bpmn_process, attrs, elements}
```

- `attrs` — A map with `:id`, `:name`, and other process-level metadata
- `elements` — A list of `{type, attrs}` tuples for each element in the process

### 2. Extract and Register the Process

```elixir
[process | _] = diagram.processes
Rodar.Registry.register("hello-world", process)
```

The Registry stores the process definition so instances can be created later.
You can register multiple versions of the same process — each call increments
the version number.

### 3. Create and Run an Instance

```elixir
{:ok, pid} = Rodar.Process.create_and_run("hello-world", %{})
```

This:
1. Looks up the latest version of `"hello-world"` in the Registry
2. Creates a new Context GenServer with the process definition
3. Activates the process (starts token flow from the start event)

The second argument is the initial data map — empty here since our hello world
doesn't need any data.

### 4. Check the Status

```elixir
Rodar.Process.status(pid)
# => :completed
```

The process ran from start to end with no interruptions, so it's `:completed`.

## Understanding the Context

The context is a **GenServer** (a PID), not a data structure. You interact with
it through the `Rodar.Context` module:

```elixir
context = Rodar.Process.get_context(pid)

# Read the process data
Rodar.Context.get_data(context, "some_key")

# Write process data
Rodar.Context.put_data(context, "result", "hello!")

# Get execution history
Rodar.Context.get_history(context)
```

**Common mistake**: Don't try to pattern-match on the context or access it like a
map. It's a PID!

```elixir
# This will crash:
%{data: data} = context

# This is correct:
data = Rodar.Context.get_data(context, "key")
```

## Exercise

Open `lib/rodar_training/exercises/ex01_first_process.ex` and implement the
`run/0` function. It should:

1. Read the `01_hello_world.bpmn` file from `priv/bpmn/`
2. Parse it with `Rodar.Engine.Diagram.load/1`
3. Register the process as `"hello-world"`
4. Create and run an instance with empty data
5. Return `{:ok, status}` where `status` is the process status

Run the test to verify:

```shell
mix test test/rodar_training/exercises/ex01_first_process_test.exs
```

## What's Next?

Now that you can run a process, let's make it do something useful. In
[Chapter 3: Service Tasks](03_service_tasks.md), you'll add handlers that
execute real business logic.
