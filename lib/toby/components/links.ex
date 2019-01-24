defmodule Toby.Components.Links do
  @moduledoc """
  A partial view to display process or port links.
  """

  @behaviour Ratatouille.Component.Stateless

  import Ratatouille.View

  @impl true
  def render(links) do
    panel(title: "Links (#{length(links)})") do
      table do
        for link <- links do
          table_row do
            table_cell(content: inspect(link))
          end
        end
      end
    end
  end
end
