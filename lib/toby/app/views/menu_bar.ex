defmodule Toby.App.Views.MenuBar do
  @moduledoc """
  Builds the menu bar for the application.
  """

  import Ratatouille.View
  import Ratatouille.Constants, only: [color: 1]

  def render(node) do
    bar do
      label do
        text(
          color: color(:black),
          background: color(:white),
          content: "#{node.current} ([N]odes)"
        )
      end
    end
  end
end
