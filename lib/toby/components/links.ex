defmodule Toby.Components.Links do
  @moduledoc """
  A partial view to display process or port links.
  """

  @behaviour Toby.Component.Stateless

  import ExTermbox.Renderer.View

  def render(links) do
    panel(title: "Links (#{length(links)})") do
      table do
        for link <- links, do: table_row([inspect(link)])
      end
    end
  end
end
