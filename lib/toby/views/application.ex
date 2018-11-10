defmodule Toby.Views.Application do
  import ExTermbox.Renderer.View

  alias Toby.Views.StatusBar

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
