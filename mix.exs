defmodule Toby.Mixfile do
  use Mix.Project

  def project do
    [
      app: :toby,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Toby.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:ex_termbox, "~> 0.1.0"}
      {:ex_termbox, path: "../ex_termbox"},
      {:credo, "~> 1.0", runtime: false},
      {:distillery, "~> 2.0"},
      {:logger_file_backend, "~> 0.0.10"}
    ]
  end
end
