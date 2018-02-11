defmodule Toby.Views.Application do
  import Toby.Formatting
  import ExTermbox.Renderer.View

  alias Toby.Views.StatusBar

  def render(%{applications: apps}) do
    view do
      columned_layout do
        panel(title: "Applications") do
          element(:table, app_rows(apps))
        end

        panel(title: "TODO") do
        end
      end

      StatusBar.render(%{selected: "Applications"})
    end
  end

  def app_rows(apps) do
    Enum.map(apps, fn app -> element(:table_row, [to_string(app)]) end)
  end
end
