defmodule Toby.Components.Memory do
  @moduledoc """
  TODO: A component for displaying information about memory usage
  """

  @behaviour Toby.Component

  import ExTermbox.Renderer.View

  alias Toby.Components.StatusBar

  def handle_event(_event, state), do: {:ok, state}

  def tick(state), do: {:ok, state}

  def render(%{}) do
    status_bar = StatusBar.render(%{selected: :memory})

    view(bottom_bar: status_bar) do
    end
  end
end
