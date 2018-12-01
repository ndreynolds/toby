defmodule Toby.Views.Load do
  import ExTermbox.Renderer.View

  alias Toby.Views.StatusBar

  def render(%{}) do
    status_bar = StatusBar.render(%{selected: :load})

    view(bottom_bar: status_bar) do
    end
  end
end
