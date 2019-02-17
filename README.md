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

## Termbox NIFs & Comparison to Other Approaches

### How does this compare to other tools like observer_cli and etop?

These are nice tools written in pure Erlang, but I was looking for a user
experience closer to htop or terminal vim/emacs. Pure-Erlang tools cannot access
raw terminal events; they can only get line-buffered input (i.e., some
characters and then a return).

Because toby uses the termbox library (an alternative to ncurses) under the
hood, it can support interactions like scrolling with the keyboard or mouse,
clicking, or pressing a single key to perform an action. It also doesn't flicker
on updates, and it can respond to window resizes by automatically performing a
relayout of the content. These things unfortunately aren't possible in pure
Erlang, as it requires putting the terminal into "raw" mode. Toby relies on NIFs
from ex_termbox in order to do this.

### Isn't it dangerous to use NIFs?

Yes, it certainly is, but the idea isn't to run this in the same VM as your
production code.

Rather, it's to run toby as a separate, hidden node and simply connect it to
your node or cluster via Erlang distribution protocol. This is similar to how a
C node works. By running toby in a separate VM, even if one of the NIFs causes a
segfault in the observer node, it should not affect the node(s) being observed.

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
