defmodule Toby do
  @moduledoc """
  Defines the supervision tree for the application
  """

  use Application

  def start(_type, _args) do
    runtime_opts = [
      app: Toby.App,
      shutdown: {:application, :toby}
    ]

    children = [
      {Ratatouille.Runtime.Supervisor, runtime: runtime_opts},
      Toby.Data.Server
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: Toby.Supervisor
    )
  end

  def stop(_state) do
    # Do a hard shutdown after the application has been stopped.
    #
    # Another, perhaps better, option is `System.stop/0`, but this results in a
    # rather annoying lag when quitting the terminal application.
    System.halt()
  end

  @version Mix.Project.config()[:version]

  def version, do: @version
end
