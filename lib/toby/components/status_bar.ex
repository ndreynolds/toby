defmodule Toby.Components.StatusBar do
  @moduledoc """
  A component that displays the status bar for navigation between views.
  """

  @behaviour Ratatouille.Component.Stateless

  import Ratatouille.Renderer.View
  import Ratatouille.Constants, only: [attribute: 1]

  @default_options [
    {:system, "[S]ystem"},
    {:load, "[L]oad Charts"},
    {:memory, "[M]emory Allocators"},
    {:application, "[A]pplications"},
    {:process, "[P]rocesses"},
    {:port, "Po[r]ts"}
  ]

  @style_selected [
    attributes: [attribute(:bold)]
  ]

  def render(%{options: options} = attrs) do
    bar do
      label do
        render_options(options, attrs[:selected])
      end
    end
  end

  def render(%{} = attrs) do
    attrs
    |> Map.merge(%{options: @default_options})
    |> render()
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
