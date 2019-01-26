defmodule Toby.App do
  @moduledoc """
  The main application.
  """

  @behaviour Ratatouille.App

  alias Toby.Cursor
  alias Toby.Data.Server, as: Data

  alias Toby.Views.{
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
  @escape key(:esc)

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
      overlay: nil,
      window: window
    }
  end

  @impl true
  def update(model, msg) do
    case msg do
      {:event, %{ch: ch}} when ch in [?s, ?S] ->
        reload(%{model | selected_tab: :system})

      {:event, %{ch: ch}} when ch in [?l, ?L] ->
        reload(%{model | selected_tab: :load})

      {:event, %{ch: ch}} when ch in [?m, ?M] ->
        reload(%{model | selected_tab: :memory})

      {:event, %{ch: ch}} when ch in [?p, ?P] ->
        reload(%{model | selected_tab: :processes})

      {:event, %{ch: ch}} when ch in [?r, ?R] ->
        reload(%{model | selected_tab: :ports})

      {:event, %{ch: ch}} when ch in [?a, ?A] ->
        reload(%{model | selected_tab: :applications})

      {:event, %{ch: ch}} when ch in [?n, ?N] ->
        %{model | overlay: :node_selection}

      {:event, %{ch: ch, key: key}} when ch == ?j or key == @arrow_down ->
        model |> update_cursor(:next) |> reload()

      {:event, %{ch: ch, key: key}} when ch == ?k or key == @arrow_up ->
        model |> update_cursor(:prev) |> reload()

      {:event, %{key: @escape}} ->
        %{model | overlay: nil}

      {:resize, %{height: height, width: width}} ->
        %{model | window: %{height: height, width: width}}

      :tick ->
        reload(model)

      _ ->
        model
    end
  end

  @impl true
  def render(%{selected_tab: selected_tab, node: node, window: window} = model) do
    menu_bar = MenuBar.render(node)
    status_bar = StatusBar.render(selected_tab)

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

  defp reload(%{node: %{status: :not_loaded}} = model) do
    {:ok, visible} = :net_adm.names()

    reload(%{
      model
      | node: %{
          current: Node.self(),
          cookie: Node.get_cookie(),
          connected_nodes: Node.list(),
          visible_nodes: visible
        }
    })
  end

  defp reload(%{selected_tab: :system} = model) do
    put_in(model, [:tabs, :system], %{
      cpu: Data.fetch!(:cpu),
      limits: Data.fetch!(:limits),
      memory: Data.fetch!(:memory),
      statistics: Data.fetch!(:statistics),
      system: Data.fetch!(:system)
    })
  end

  defp reload(%{selected_tab: :applications} = model) do
    applications = Data.fetch!(:applications) |> Enum.sort_by(&to_string/1)
    cursor = model.tabs.applications[:cursor] || 0
    selected_key = Enum.at(applications, cursor)

    put_in(model, [:tabs, :applications], %{
      applications: applications,
      selected: Data.fetch!({:application, selected_key}),
      cursor: cursor,
      size: length(applications)
    })
  end

  defp reload(%{selected_tab: :processes} = model) do
    processes = Data.fetch!(:processes)

    put_in(model, [:tabs, :processes], %{
      processes: processes,
      cursor: model.tabs.processes[:cursor] || 0,
      size: length(processes)
    })
  end

  defp reload(%{selected_tab: :ports} = model) do
    ports = Data.fetch!(:ports)

    put_in(model, [:tabs, :ports], %{
      ports: ports,
      cursor: model.tabs.ports[:cursor] || 0,
      size: length(ports)
    })
  end

  defp reload(%{selected_tab: :load} = model) do
    %{schedulers: scheduler_count} = Data.fetch!(:cpu)

    put_in(model, [:tabs, :load], %{
      utilization: Data.fetch!(:historical_scheduler_utilization),
      scheduler_count: scheduler_count,
      memory: Data.fetch!(:historical_memory),
      io: Data.fetch!(:historical_io),
      cursor: model.tabs.load[:cursor] || 0,
      size: scheduler_count + 1
    })
  end

  defp reload(model) do
    model
  end

  defp update_cursor(model, direction) do
    update_in(model, [:tabs, model.selected_tab, :cursor], fn
      nil ->
        nil

      cursor ->
        size = model.tabs[model.selected_tab].size

        case direction do
          :prev -> Cursor.previous(cursor, size)
          :next -> Cursor.next(cursor, size)
        end
    end)
  end
end
