defmodule Toby.Views.StatusBar do
  import ExTermbox.Renderer.View

  alias ExTermbox.Constants

  @default_options [
    "System",
    "Load Charts",
    "Memory Allocators",
    "Applications",
    "Processes",
    "Ports"
  ]

  @style_selected %{
    attributes: [Constants.attribute(:bold)]
  }

  def render(%{options: options} = attrs) do
    element(:status_bar, [
      element(:text_group, render_options(options, attrs[:selected]))
    ])
  end

  def render(%{} = attrs),
    do: attrs |> Map.merge(%{options: @default_options}) |> render()

  defp render_options(options, selected_option) do
    options
    |> Enum.map(&render_option(&1, &1 == selected_option))
    |> Enum.intersperse(whitespace())
  end

  defp render_option(name, selected) do
    element(:text, if(selected, do: @style_selected, else: %{}), [name])
  end

  defp whitespace, do: element(:text, ["  "])
end
