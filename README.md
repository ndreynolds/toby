# Toby

A WIP terminal-based observer for the Erlang VM. Just an early prototype here
so far.

It's being developed in parallel with [ex_termbox][1], which renders the
terminal and provides a view and eventing library.

![Applications Tab](doc/applications.png)
![Load Tab](doc/load-charts.png)
![Processes](doc/processes.png)

## Usage

```bash
mix run --no-halt
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `toby` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:toby, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/toby](https://hexdocs.pm/toby).

[1]: https://github.com/ndreynolds/ex_termbox
