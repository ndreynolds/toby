# Toby

A WIP terminal-based observer for the Erlang VM. Just an early prototype here
so far.

It's being developed in parallel with [ExTermbox][1] and [Ratatouille][2], which
respectively provide termbox bindings and a terminal UI kit for Elixir / Erlang.

![Applications Tab](doc/applications.png)
![Load Tab](doc/load-charts.png)
![Processes Tab](doc/processes.png)
![System Tab](doc/system.png)

## Running It

First, clone the repo and run `mix deps.get`. Then to run the application:

```bash
mix run --no-halt
```

Currently, you can only see information about the local node (i.e., the one you
just started), but soon you'll also be able to connect to other nodes like you
can with the observer GUI.

## Building a Release

It's also possible to create a distributable, self-contained executable via
Distillery. I'd like to provide these for download in the future, but for now
you can build one yourself using the provided config.

Releases built on a given architecture can generally be run on machines of the
same architecture.

```bash
MIX_ENV=prod mix release --executable --transient
```

See the output for the location of the built executable (most likely at
`_build/prod/rel/toby/bin/toby.run`).

This is a Distillery release that bundles the Erlang runtime and the toby
application. Start it in the foreground:

```bash
_build/prod/rel/toby/bin/toby.run foreground
```

You can also move this executable somewhere else (e.g., to a directory in your
$PATH). A current caveat is that it must be able to unpack itself, as Distillery
executables are self-extracting archives.

## Roadmap

* [ ] Implement views from observer on a basic level:
  * [x] System
  * [x] Load Charts
  * [ ] Memory Allocators
  * [x] Applications
  * [x] Processes
  * [x] Ports
  * [ ] Tables
  * [x] Node information
* [ ] Support connecting to other nodes:
  * [ ] Via the application UI
  * [ ] Via the CLI
* [ ] Actions on applications, ports, processes and tables.
* [ ] Tracing integration

[1]: https://github.com/ndreynolds/ex_termbox
[2]: https://github.com/ndreynolds/ratatouille
