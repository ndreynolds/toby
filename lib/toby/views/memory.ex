defmodule Toby.Views.Memory do
  import ExTermbox.Renderer.View

  alias Toby.Views.StatusBar

  def render(%{}) do
    status_bar = StatusBar.render(%{selected: :memory})

    view(bottom_bar: status_bar) do
    end
  end
end
