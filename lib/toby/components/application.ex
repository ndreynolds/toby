defmodule Toby.Components.Application do
  @moduledoc """
  A component for displaying information about OTP applications
  """

  @behaviour Toby.Component

  import ExTermbox.Renderer.View

  alias Toby.Components.StatusBar
  alias Toby.Stats.Server, as: Stats

  def handle_event(_event, state), do: {:ok, state}

  def tick(_state) do
    {:ok, %{applications: Stats.fetch(:applications)}}
  end

  def render(%{applications: apps}) do
    status_bar = StatusBar.render(%{selected: :application})

    view(bottom_bar: status_bar) do
      row do
        column(size: 6) do
          panel(title: "Applications") do
            element(:table, app_rows(apps))
          end
        end

        column(size: 6) do
          panel(title: "TODO") do
          end
        end
      end
    end
  end

  def app_rows(apps) do
    for app <- apps, do: table_row([to_string(app)])
  end
end
