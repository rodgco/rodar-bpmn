# Chapter 7: Expressions (FEEL & Elixir)

Rodar supports two expression languages for conditions and script tasks:
**FEEL** (Friendly Enough Expression Language) and **Elixir**. Understanding
when and how to use each is essential.

## FEEL vs Elixir

| Feature | FEEL | Elixir |
|---------|------|--------|
| Binding | Direct: `total > 100` | Via data map: `data["total"] > 100` |
| Null handling | Three-valued logic | Standard Elixir nil |
| Standard | DMN/BPMN standard | Rodar-specific |
| Best for | Business rules, portability | Complex logic, Elixir integration |

### FEEL Expressions

FEEL is the standard expression language for BPMN/DMN. In Rodar, FEEL
bindings receive the process data map directly — you write expressions
naturally:

```xml
<!-- FEEL condition: access data directly -->
<bpmn:conditionExpression language="feel">total >= 500</bpmn:conditionExpression>
```

If the process data is `%{"total" => 600}`, this evaluates to `true`.

### Elixir Expressions

Elixir expressions access data through a `data` binding:

```xml
<!-- Elixir condition: access via data map -->
<bpmn:conditionExpression language="elixir">data["total"] >= 500</bpmn:conditionExpression>
```

Elixir expressions run in a sandbox with restricted AST — you can't call
arbitrary functions or access the filesystem.

## The Discount Rules Diagram

Open `priv/bpmn/06_discount_rules.bpmn`:

```
                    +--> [Gold: 20% off]   --+
[Start] --> <X>  ---+--> [Silver: 10% off] --+--> [End]
                    +--> [No Discount]     --+
```

This diagram uses **FEEL conditions** on the gateway and **FEEL script tasks**
to calculate discounts:

- `total >= 500` → Gold discount (20%)
- `total >= 100 and total < 500` → Silver discount (10%)
- Default → No discount

The script tasks use FEEL to compute the discount:

```xml
<bpmn:scriptTask id="Task_Gold" name="Apply Gold Discount" scriptFormat="feel">
  <bpmn:script>{ discount: total * 0.20, tier: "gold" }</bpmn:script>
</bpmn:scriptTask>
```

## FEEL Features

### Arithmetic

```
total * 0.20
price + tax
quantity - returned
```

### Comparisons

```
total >= 500
status = "active"
count != 0
```

### Boolean Logic

```
total >= 100 and total < 500
status = "vip" or total >= 1000
not(expired)
```

### Built-in Functions

```
string length("hello")     # => 5
upper case("hello")        # => "HELLO"
contains("foobar", "bar")  # => true
abs(-42)                   # => 42
sum([1, 2, 3])             # => 6
count([1, 2, 3])           # => 3
```

### Null Propagation

FEEL handles null values gracefully — most operations on null return null
instead of crashing:

```
null + 5        # => null
null > 10       # => null (not true or false)
is null(x)      # => true if x is null
```

## Running the Example

```elixir
xml = File.read!("priv/bpmn/06_discount_rules.bpmn")
diagram = Rodar.Engine.Diagram.load(xml)
[process | _] = diagram.processes

Rodar.Registry.register("discount-rules", process)

# Gold tier
{:ok, pid} = Rodar.Process.create_and_run("discount-rules", %{"total" => 600})
context = Rodar.Process.get_context(pid)
Rodar.Context.get_data(context, "tier")
# => "gold"
Rodar.Context.get_data(context, "discount")
# => 120.0
```

## Common Mistakes

**Using Elixir syntax in FEEL**: `data["total"]` doesn't work in FEEL. Just
write `total`.

**Using FEEL syntax in Elixir**: `total > 5` doesn't work in Elixir expressions.
Write `data["total"] > 5`.

**Forgetting the `language` attribute**: Without it, the engine may default to
one language when you meant the other.

## Exercise

This chapter uses script tasks (FEEL-based), so there's no handler to write.
Instead, experiment in IEx:

```elixir
# Try different totals and observe the discount tier
iex> xml = File.read!("priv/bpmn/06_discount_rules.bpmn")
iex> diagram = Rodar.Engine.Diagram.load(xml)
iex> [process | _] = diagram.processes
iex> Rodar.Registry.register("discount-rules", process)

iex> {:ok, pid} = Rodar.Process.create_and_run("discount-rules", %{"total" => 50})
iex> Rodar.Context.get_data(Rodar.Process.get_context(pid), "tier")
# What do you expect?
```

## What's Next?

In [Chapter 8: Combining It All](08_combining_it_all.md), you'll build a
complete approval workflow that combines service tasks, user tasks, exclusive
gateways, and expressions.
