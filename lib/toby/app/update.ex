defmodule Toby.App.Update do
  @moduledoc """
  Functions to update the model
  """

  alias Toby.Data.Server, as: Data
  alias Toby.Util.{Cursor, Tree}

  alias Ratatouille.Runtime.Command

  import Ratatouille.Constants, only: [key: 1]

  @escape key(:esc)
  @backspace key(:backspace2)
  @enter key(:enter)

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

  def overlay_action(%{overlay: :node_selection} = model, %{key: @enter}) do
    %{cursor: cursor, data: %{connected_nodes: nodes}} = model.node

    node = Enum.at(nodes, cursor.position)
    new_model = %{model | selected_node: node}

    {new_model,
     Command.batch([
       request_refresh(new_model, :node),
       request_refresh(new_model, model.selected_tab),
       Command.new(fn -> Data.set_sample_source(node) end, :set_sample_source)
     ])}
  end

  def overlay_action(%{overlay: :node_selection} = model, %{ch: ch}) when ch == ?j do
    move_cursor(model, [:node, :cursor_y], :next)
  end

  def overlay_action(%{overlay: :node_selection} = model, %{ch: ch}) when ch == ?k do
    move_cursor(model, [:node, :cursor_y], :prev)
  end

  def overlay_action(model, %{key: @escape}) do
    %{model | overlay: nil}
  end

  def overlay_action(model, _event) do
    model
  end

  # TODO: Would this be a useful abstraction? The applications UI is really just
  # a tree view where you can drill down into nodes (apps -> app -> process).
  #
  # It might be helpful for each view to define a more structured interface for
  # how it handles cursor events (with defaults for common use cases).
  def move_cursor(model, [:tabs, :applications, :cursor_x], direction) do
    tab = model.tabs.applications
    cursor_x = new_cursor(tab.cursor_x, direction)

    cursors_y =
      for {cursor, i} <- Enum.with_index(tab.cursors_y) do
        if i > cursor_x.position, do: Cursor.reset(cursor), else: cursor
      end

    new_model =
      model
      |> put_in([:tabs, :applications, :cursor_x], cursor_x)
      |> put_in([:tabs, :applications, :cursors_y], cursors_y)

    {new_model, request_refresh(new_model, new_model.selected_tab)}
  end

  def move_cursor(model, [:tabs, :applications, :cursor_y], direction) do
    tab = model.tabs.applications
    cursor_x = tab.cursor_x

    cursors_y =
      List.update_at(tab.cursors_y, cursor_x.position, &new_cursor(&1, direction))

    new_model = put_in(model, [:tabs, :applications, :cursors_y], cursors_y)
    {new_model, request_refresh(new_model, new_model.selected_tab)}
  end

  def move_cursor(model, cursor_path, direction) do
    new_model = update_in(model, cursor_path, &new_cursor(&1, direction))
    {new_model, request_refresh(new_model, new_model.selected_tab)}
  end

  defp new_cursor(nil, _direction), do: nil
  defp new_cursor(cursor, :prev), do: Cursor.previous(cursor)
  defp new_cursor(cursor, :next), do: Cursor.next(cursor)

  def select_tab(model, tab_id) do
    new_model = %{model | selected_tab: tab_id}
    {new_model, request_refresh(new_model, tab_id)}
  end

  def request_refresh(model, :applications) do
    Command.new(
      fn ->
        %{applications: applications} = Data.fetch!({model.selected_node, :applications})

        [app_cursor, proc_cursor] = model.tabs.applications.cursors_y

        selected_app_id = Enum.at(applications, app_cursor.position)
        selected_app = Data.fetch!({model.selected_node, :application, selected_app_id})

        selected_proc =
          case selected_app do
            nil ->
              nil

            app ->
              {{selected_proc_id, _}, _} =
                Tree.node_at(app.process_tree, proc_cursor.position)

              Data.fetch!({model.selected_node, :lookup, selected_proc_id})
          end

        %{
          applications: applications,
          selected_application: selected_app,
          selected_process: selected_proc
        }
      end,
      {:refreshed, :applications}
    )
  end

  def request_refresh(model, key) do
    Command.new(
      fn -> Data.fetch!({model.selected_node, key}) end,
      {:refreshed, key}
    )
  end

  def refresh(model, :node, data) do
    model
    |> update_in([:node, :cursor_y], &Cursor.put_size(&1, length(data.connected_nodes)))
    |> put_in([:node, :data], data)
  end

  def refresh(model, :processes, data) do
    filtered_processes = filter(:processes, data.processes, model.search.query)

    model
    |> put_in([:tabs, :processes, :data], data)
    |> update_in(
      [:tabs, :processes, :cursor_y],
      &Cursor.put_size(&1, length(data.processes))
    )
    |> put_in([:tabs, :processes, :filtered], filtered_processes)
  end

  def refresh(model, :ports, data) do
    model
    |> put_in([:tabs, :ports, :data], data)
    |> update_in([:tabs, :ports, :cursor_y], &Cursor.put_size(&1, length(data.ports)))
  end

  def refresh(model, :load, data) do
    model
    |> put_in([:tabs, :load, :data], data)
    |> update_in(
      [:tabs, :load, :cursor_y],
      &Cursor.put_size(&1, data.scheduler_count + 1)
    )
  end

  def refresh(model, :memory, data) do
    model
    |> put_in([:tabs, :memory, :data], data)
    |> update_in(
      [:tabs, :memory, :cursor_y],
      &Cursor.put_size(&1, length(data.allocator_names))
    )
  end

  def refresh(model, :tables, data) do
    model
    |> put_in([:tabs, :tables, :data], data)
    |> update_in([:tabs, :tables, :cursor_y], &Cursor.put_size(&1, length(data.tables)))
  end

  def refresh(model, :applications, data) do
    model
    |> put_in([:tabs, :applications, :data], data)
    |> update_in(
      [:tabs, :applications, :cursors_y],
      fn [app_cursor, app_tree_cursor] ->
        [
          Cursor.put_size(app_cursor, length(data.applications)),
          case data.selected_application do
            nil -> app_tree_cursor
            app -> Cursor.put_size(app_tree_cursor, app.process_tree_size)
          end
        ]
      end
    )
  end

  def refresh(model, tab, data) do
    put_in(model, [:tabs, tab, :data], data)
  end

  defp filter(:processes, processes, ""), do: processes

  defp filter(:processes, processes, query) do
    processes
    |> Enum.filter(fn p ->
      String.contains?(to_string(p[:registered_name]), query) ||
        String.contains?(inspect(p.current_function), query)
    end)
  end
end
