# CLI Tools

The library provides Mix tasks for working with BPMN files from the command line.

## `mix rodar_bpmn.validate`

Validate a BPMN 2.0 XML file for structural issues:

```shell
mix rodar_bpmn.validate path/to/process.bpmn
```

Runs 9 structural validation rules on each process:

- Start/end event existence and connectivity
- Sequence flow reference integrity
- Orphan node detection
- Gateway outgoing flow counts
- Exclusive gateway default flow (warning)
- Boundary event attachment

If a collaboration element is present, cross-process constraints are also checked (participant refs, message flow refs).

Exit code 0 on clean or warnings-only, exit code 1 on errors.

## `mix rodar_bpmn.inspect`

Print the parsed structure of a BPMN file:

```shell
mix rodar_bpmn.inspect path/to/process.bpmn
```

Output includes:

- Diagram ID
- Each process with element counts grouped by type
- Element IDs for each type
- Collaboration info (participants, message flows) if present

## `mix rodar_bpmn.run`

Execute a BPMN process from an XML file:

```shell
mix rodar_bpmn.run path/to/process.bpmn
mix rodar_bpmn.run path/to/process.bpmn --data '{"username": "alice"}'
```

Starts the application, registers the first process in the file, creates an instance, and runs it. Prints the final status and context data.

The `--data` flag accepts a JSON object that is passed as initial data to the process context.

## `mix rodar_bpmn.export`

Export a BPMN file as normalized BPMN 2.0 XML:

```shell
mix rodar_bpmn.export path/to/process.bpmn
mix rodar_bpmn.export path/to/process.bpmn --output normalized.bpmn
```

Parses the input file and re-exports it as normalized BPMN 2.0 XML. This is useful for:

- Normalizing XML formatting across different BPMN editors
- Stripping vendor-specific extensions (e.g., Camunda, Drools attributes)
- Verifying round-trip fidelity of the parser

Prints to stdout by default. Use `--output` to write to a file instead.

## `mix rodar_bpmn.scaffold`

Generate handler module stubs from a BPMN file:

```shell
mix rodar_bpmn.scaffold path/to/order.bpmn
mix rodar_bpmn.scaffold path/to/order.bpmn --output-dir lib/my_app/handlers
mix rodar_bpmn.scaffold path/to/order.bpmn --module-prefix MyApp.Handlers
mix rodar_bpmn.scaffold path/to/order.bpmn --dry-run
mix rodar_bpmn.scaffold path/to/order.bpmn --force
```

Parses the BPMN file, identifies all actionable tasks (service, user, send, receive, manual, and generic), and generates handler module files with the correct behaviour and callback stubs.

### Options

| Flag | Alias | Description |
|------|-------|-------------|
| `--output-dir DIR` | `-o` | Override the default output directory |
| `--module-prefix PREFIX` | `-p` | Override the derived module prefix |
| `--dry-run` | `-d` | Print generated code to stdout instead of writing files |
| `--force` | `-f` | Overwrite existing files without prompting |

### Defaults

- **Output directory**: `lib/<app_name>/bpmn/handlers/<bpmn_filename>/`
- **Module prefix**: `<AppName>.Bpmn.Handlers.<BpmnFilename>`

### Task type mapping

- Service tasks (`:bpmn_activity_task_service`) get the `RodarBpmn.Activity.Task.Service.Handler` behaviour with an `execute/2` callback
- All other task types (user, send, receive, manual, generic) get the `RodarBpmn.TaskHandler` behaviour with a `token_in/2` callback

### Conflict handling

When a target file already exists and `--force` is not set, the task shows a diff and prompts:

- **Overwrite** — replace the existing file
- **Keep both** — write a new file with a `New` suffix
- **Skip** — leave the existing file unchanged

After writing files, the task prints registration instructions showing how to wire the generated handlers (via `handler_map` for service tasks, or `TaskRegistry` for others).

## Next Steps

- [Getting Started](getting_started.md) — Installation and basic concepts
- [Process Lifecycle](process_lifecycle.md) — Instance creation and status transitions
