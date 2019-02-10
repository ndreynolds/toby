defmodule Toby.App do
  @moduledoc """
  The main application.
  """

  @behaviour Ratatouille.App

  alias Toby.App.Update

  alias Toby.App.Views.{
    Applications,
    Load,
    Memory,
    MenuBar,
    NodeSelect,
    Ports,
    Processes,
    StatusBar,
    System
  }

  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  @tab_keymap %{
    ?s => :system,
    ?S => :system,
    ?l => :load,
    ?L => :load,
    ?m => :memory,
    ?M => :memory,
    ?a => :applications,
    ?A => :applications,
    ?p => :processes,
    ?P => :processes,
    ?r => :ports,
    ?R => :ports
  }
  @tab_keys Map.keys(@tab_keymap)

  @impl true
  def model(%{window: window}) do
    %{
      selected_tab: :system,
      tabs: %{
        system: %{status: :not_loaded},
        load: %{status: :not_loaded},
        memory: %{status: :not_loaded},
        applications: %{status: :not_loaded},
        processes: %{status: :not_loaded},
        ports: %{status: :not_loaded}
      },
      node: %{
        status: :not_loaded
      },
      search: %{
        focused: false,
        query: ""
      },
      overlay: nil,
      window: window
    }
  end

  @impl true
  def update(model, msg) do
    case {model, msg} do
      ## Search:

      {_, {:event, %{ch: ?/}}} ->
        Update.focus_search(model)

      {%{search: %{focused: true}}, {:event, event}} ->
        Update.search(model, event)

      ## Change the selected tab:

      {_, {:event, %{ch: ch}}} when ch in @tab_keys ->
        Update.select_tab(model, @tab_keymap[ch])

      ## Show or act on an overlay:

      {_, {:event, %{ch: ch}}} when ch in [?n, ?N] ->
        Update.show_overlay(model, :node_selection)

      {%{overlay: overlay}, {:event, event}} when not is_nil(overlay) ->
        Update.overlay_action(model, event)

      ## Move the active cursor:

      {_, {:event, %{ch: ch, key: key}}} when ch == ?j or key == @arrow_down ->
        Update.move_cursor(model, :next)

      {_, {:event, %{ch: ch, key: key}}} when ch == ?k or key == @arrow_up ->
        Update.move_cursor(model, :prev)

      ## Update the window in response to resize:

      {_, {:resize, event}} ->
        Update.resize(model, event)

      ## Handle tick:

      {_, :tick} ->
        Update.reload(model)

      ## Unhandled events (no update):

      _ ->
        model
    end
  end

  @impl true
  def render(%{selected_tab: selected_tab, search: search, node: node, window: window} = model) do
    menu_bar = MenuBar.render(node)
    status_bar = StatusBar.render(selected_tab, search)

    view(top_bar: menu_bar, bottom_bar: status_bar) do
      case selected_tab do
        :system ->
          System.render(model.tabs.system)

        :load ->
          Load.render(model.tabs.load)

        :memory ->
          Memory.render(model.tabs.memory)

        :applications ->
          Applications.render(model.tabs.applications)

        :processes ->
          Processes.render(model.tabs.processes, window)

        :ports ->
          Ports.render(model.tabs.ports, window)
      end

      if model.overlay == :node_selection do
        overlay(padding: 10) do
          NodeSelect.render(model.node)
        end
      end
    end
  end
end
