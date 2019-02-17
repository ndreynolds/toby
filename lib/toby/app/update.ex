defmodule Toby.App.Update do
  @moduledoc """
  Functions to update the model
  """

  alias Toby.Data.Server, as: Data
  alias Toby.Util.Cursor

  alias Ratatouille.Runtime.Command

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
    new_model =
      update_in(model, [:tabs, model.selected_tab, :cursor], &new_cursor(&1, direction))

    {new_model, request_tab_refresh(new_model)}
  end

  defp new_cursor(nil, _direction), do: nil
  defp new_cursor(cursor, :prev), do: Cursor.previous(cursor)
  defp new_cursor(cursor, :next), do: Cursor.next(cursor)

  def select_tab(model, id) do
    new_model = %{model | selected_tab: id}
    {new_model, request_tab_refresh(new_model)}
  end

  def request_node_refresh do
    Command.new(fn -> Data.fetch!(:node) end, {:refreshed, :node})
  end

  def request_tab_refresh(%{selected_tab: :applications} = model) do
    Command.new(
      fn ->
        data = Data.fetch!(:applications)

        cursor =
          Cursor.put_size(model.tabs.applications.cursor, length(data.applications))

        selected = Enum.at(data.applications, cursor.position)
        selected_data = Data.fetch!({:application, selected})

        %{
          applications: data.applications,
          selected_application: selected_data
        }
      end,
      {:refreshed, :applications}
    )
  end

  def request_tab_refresh(%{selected_tab: tab}) do
    Command.new(
      fn -> Data.fetch!(tab) end,
      {:refreshed, tab}
    )
  end

  def refresh_tab(model, tab, data) do
    model
    |> put_in([:tabs, tab, :data], data)
    |> after_tab_refresh(tab, data)
  end

  defp after_tab_refresh(model, :processes, data) do
    filtered_processes = filter(:processes, data.processes, model.search.query)

    model
    |> update_tab_cursor(:processes, &Cursor.put_size(&1, length(data.processes)))
    |> put_in([:tabs, :processes, :filtered], filtered_processes)
  end

  defp after_tab_refresh(model, :ports, data) do
    update_tab_cursor(model, :ports, &Cursor.put_size(&1, length(data.ports)))
  end

  defp after_tab_refresh(model, :load, data) do
    update_tab_cursor(model, :load, &Cursor.put_size(&1, data.scheduler_count + 1))
  end

  defp after_tab_refresh(model, :applications, data) do
    update_tab_cursor(
      model,
      :applications,
      &Cursor.put_size(&1, length(data.applications))
    )
  end

  defp after_tab_refresh(model, _tab, _data) do
    model
  end

  defp filter(:processes, processes, ""), do: processes

  defp filter(:processes, processes, query) do
    processes
    |> Enum.filter(fn p ->
      String.contains?(to_string(p[:registered_name]), query) ||
        String.contains?(inspect(p.current_function), query)
    end)
  end

  defp update_tab_cursor(model, tab, update_fun) do
    cursor = model[:tabs][tab][:cursor]
    new_cursor = update_fun.(cursor)
    put_in(model, [:tabs, tab, :cursor], new_cursor)
  end
end
