defmodule Toby.App.Views.Applications do
  @moduledoc """
  Builds a view that displays information about OTP applications
  """

  import Toby.App.Views.Processes, only: [process_details: 1]
  import Toby.App.Views.Ports, only: [port_details: 1]

  import Ratatouille.Constants, only: [color: 1]
  import Ratatouille.View

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def render(%{
        data: %{
          applications: apps,
          selected_application: selected_app,
          selected_process: selected_proc
        },
        cursor_x: pane_cursor,
        cursors_y: [_app_cursor, app_tree_cursor]
      }) do
    case pane_cursor.position do
      0 -> two_pane(apps, selected_app)
      1 -> three_pane(apps, selected_app, selected_proc, app_tree_cursor)
    end
  end

  def two_pane(apps, selected_app) do
    row do
      column(size: 6) do
        app_list(apps, selected_app)
      end

      column(size: 6) do
        panel(title: app_title(selected_app)) do
          app_tree(selected_app, nil)
        end
      end
    end
  end

  def three_pane(apps, selected_app, selected_proc, cursor) do
    row do
      column(size: 4) do
        app_list(apps, selected_app)
      end

      column(size: 4) do
        panel(title: app_title(selected_app)) do
          app_tree(selected_app, cursor)
        end
      end

      column(size: 4) do
        app_tree_node_details(selected_proc)
      end
    end
  end

  defp app_list(apps, selected_app) do
    panel(title: "Applications") do
      table do
        for app <- apps do
          table_row(if(app == selected_app.name, do: @style_selected, else: [])) do
            table_cell(content: to_string(app))
          end
        end
      end
    end
  end

  defp app_tree(nil, _cursor) do
    label(content: "(No Application)")
  end

  defp app_tree(%{process_tree: proc_tree}, cursor) when is_tuple(proc_tree) do
    tree do
      to_tree_node(proc_tree, cursor)
    end
  end

  defp app_tree(_app_without_tree, _cursor) do
    label(content: "(Application has no master process)")
  end

  defp app_tree_node_details(%{type: :port} = port) do
    port_details(port)
  end

  defp app_tree_node_details(process_or_other) do
    process_details(process_or_other)
  end

  defp app_title(%{name: name}), do: to_string(name)
  defp app_title(_other), do: ""

  defp to_tree_node({{pid_or_name, idx}, children}, cursor) do
    label = format_node(pid_or_name)

    attrs =
      if not is_nil(cursor) and idx == cursor.position do
        [content: label] ++ @style_selected
      else
        [content: label]
      end

    tree_node(
      attrs,
      for(child <- children, do: to_tree_node(child, cursor))
    )
  end

  defp format_node(pid) when is_pid(pid) do
    pid |> :erlang.pid_to_list() |> to_string()
  end

  defp format_node(port) when is_port(port) do
    inspect(port)
  end

  defp format_node(name) when is_atom(name) do
    to_string(name)
  end
end
