defmodule Toby.App.Update do
  @moduledoc """
  Functions to update the model
  """

  alias Toby.Util.Cursor

  import Toby.Data.Server, only: [fetch!: 1]
  import Ratatouille.Constants, only: [key: 1]

  @escape key(:esc)
  @backspace key(:backspace2)

  def focus_search(model) do
    put_in(model, [:search, :focused], true)
  end

  def search(model, %{key: @escape}) do
    put_in(model, [:search, :focused], false)
  end

  def search(model, %{key: @backspace}) do
    put_in(model, [:search, :query], String.slice(model.search.query, 0..-2))
  end

  def search(model, %{ch: ch}) when ch > 0 do
    put_in(model, [:search, :query], model.search.query <> <<ch::utf8>>)
  end

  def search(model, _event) do
    model
  end

  def resize(model, %{h: height, w: width}) do
    %{model | window: %{height: height, width: width}}
  end

  def select_tab(model, id) do
    reload(%{model | selected_tab: id})
  end

  def show_overlay(model, :node_selection) do
    %{model | overlay: :node_selection}
  end

  def overlay_action(model, %{key: @escape}) do
    %{model | overlay: nil}
  end

  def overlay_action(model, _event) do
    model
  end

  def move_cursor(model, direction) do
    model
    |> update_in([:tabs, model.selected_tab, :cursor], &new_cursor(&1, direction))
    |> reload()
  end

  defp new_cursor(nil, _direction), do: nil
  defp new_cursor(cursor, :prev), do: Cursor.previous(cursor)
  defp new_cursor(cursor, :next), do: Cursor.next(cursor)

  def reload(%{node: %{status: :not_loaded}} = model) do
    reload(%{model | node: data_for(:node)})
  end

  def reload(%{selected_tab: :system} = model) do
    update_tab(model, :system)
  end

  def reload(%{selected_tab: :applications} = model) do
    update_tab(model, :applications, fn data ->
      cursor =
        model
        |> fetch_tab_cursor(:applications)
        |> Cursor.put_size(length(data.applications))

      selected = fetch!({:application, Enum.at(data.applications, cursor.position)})

      Map.merge(data, %{selected: selected, cursor: cursor})
    end)
  end

  def reload(%{selected_tab: :processes, search: %{query: query}} = model) do
    update_tab(model, :processes, fn data ->
      filtered_processes = filter(:processes, data.processes, query)

      cursor =
        model
        |> fetch_tab_cursor(:processes)
        |> Cursor.put_size(length(filtered_processes))

      Map.merge(data, %{cursor: cursor, processes: filtered_processes})
    end)
  end

  def reload(%{selected_tab: :ports} = model) do
    update_tab(model, :ports, fn data ->
      cursor =
        model
        |> fetch_tab_cursor(:ports)
        |> Cursor.put_size(length(data.ports))

      Map.merge(data, %{cursor: cursor})
    end)
  end

  def reload(%{selected_tab: :load} = model) do
    update_tab(model, :load, fn data ->
      cursor =
        model
        |> fetch_tab_cursor(:load)
        |> Cursor.put_size(data.scheduler_count + 1)

      Map.merge(data, %{cursor: cursor})
    end)
  end

  def reload(model) do
    model
  end

  defp data_for(:node) do
    fetch!(:node)
  end

  defp data_for(:system) do
    %{
      cpu: fetch!(:cpu),
      limits: fetch!(:limits),
      memory: fetch!(:memory),
      statistics: fetch!(:statistics),
      system: fetch!(:system)
    }
  end

  defp data_for(:applications) do
    %{applications: fetch!(:applications) |> Enum.sort_by(&to_string/1)}
  end

  defp data_for(:processes) do
    %{processes: fetch!(:processes)}
  end

  defp data_for(:ports) do
    %{ports: fetch!(:ports)}
  end

  defp data_for(:load) do
    %{
      utilization: fetch!(:historical_scheduler_utilization),
      scheduler_count: fetch!(:cpu).schedulers,
      memory: fetch!(:historical_memory),
      io: fetch!(:historical_io)
    }
  end

  defp filter(:processes, processes, ""), do: processes

  defp filter(:processes, processes, query) do
    processes
    |> Enum.filter(fn p ->
      String.contains?(to_string(p[:registered_name]), query) ||
        String.contains?(inspect(p.current_function), query)
    end)
  end

  defp fetch_tab_cursor(model, tab) do
    model[:tabs][tab][:cursor] || %{position: 0, size: 0}
  end

  defp update_tab(model, tab, transform_fn \\ & &1) do
    data = tab |> data_for() |> transform_fn.()

    put_in(model, [:tabs, tab], data)
  end
end
