defmodule Toby.Views.Links do
  @moduledoc """
  Builds a panel to display process or port links.
  """

  import Ratatouille.View

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
