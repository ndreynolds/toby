defmodule Toby.Views.StatusBar do
  @moduledoc """
  A component that displays the status bar for navigation between views.
  """

  import Ratatouille.View
  import Ratatouille.Constants, only: [attribute: 1]

  @default_options [
    {:system, "[S]ystem"},
    {:load, "[L]oad Charts"},
    {:memory, "[M]emory Allocators"},
    {:applications, "[A]pplications"},
    {:processes, "[P]rocesses"},
    {:ports, "Po[r]ts"}
  ]

  @style_selected [
    attributes: [attribute(:bold)]
  ]

  def render(options \\ @default_options, selected) do
    bar do
      label do
        render_options(options, selected)
      end
    end
  end

  defp render_options(options, selected) do
    rendered_options =
      for {key, label} <- options do
        if key == selected do
          text(@style_selected ++ [content: label])
        else
          text(content: label)
        end
      end

    Enum.intersperse(rendered_options, text(content: " "))
  end
end
