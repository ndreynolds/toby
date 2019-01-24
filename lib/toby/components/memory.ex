defmodule Toby.Components.Memory do
  @moduledoc """
  TODO: A component for displaying information about memory usage
  """

  @behaviour Ratatouille.Component.Stateful

  import Ratatouille.View

  alias Toby.Components.StatusBar

  @impl true
  def handle_event(_event, state), do: {:ok, state}

  @impl true
  def handle_tick(state), do: {:ok, state}

  @impl true
  def render(%{}) do
    status_bar = StatusBar.render(%{selected: :memory})

    view(bottom_bar: status_bar) do
      panel title: "Carrier Size (MB)" do
        label(content: "TODO")
      end

      panel title: "Carrier Utilization (%)" do
        label(content: "TODO")
      end
    end
  end
end
