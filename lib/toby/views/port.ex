defmodule Toby.Views.Port do
  import ExTermbox.Renderer.View

  alias Toby.Views.StatusBar

  def render(%{}) do
    status_bar = StatusBar.render(%{selected: :port})

    view(bottom_bar: status_bar) do
    end
  end
end
