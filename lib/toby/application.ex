defmodule Toby.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(ExTermbox.Window, []),
      worker(ExTermbox.EventManager, []),
      Toby.Console
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: Toby.Supervisor
    )
  end
end
