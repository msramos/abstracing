# Abstracing

It's a library that helps you to create `OpenTelemetry` spans with the least effort.

When you `use Tracing` it will include all required modules to start using tracing,
as well as importing the `span/1`, `span/2` and `span/3` functions.

```elixir
defmodule MyModule do
  use Tracing

  def my_function do
    span do
      # ... some code here
    end
  end
end
```

Although it's not a fork, this project ie heavily inspired by [Hatch Tracing](https://github.com/Hatch1fy/hatch-tracing).

## Installation

The package can be installed by adding `abstracing` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:abstracing, "~> 0.1.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/abstracing>.
