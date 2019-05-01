defmodule Toby.Mixfile do
  use Mix.Project

  def project do
    [
      app: :toby,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Toby, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ratatouille, "~> 0.5"},
      # {:ratatouille, git: "https://github.com/ndreynolds/ratatouille"},
      # {:ratatouille, path: "../ratatouille"},
      {:distillery, "~> 2.0", runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      test: "test --no-start"
    ]
  end
end
