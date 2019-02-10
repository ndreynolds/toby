defmodule Toby.App.Views.Applications do
  @moduledoc """
  Builds a view that displays information about OTP applications
  """

  import Ratatouille.Constants, only: [color: 1]
  import Ratatouille.View

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def render(%{applications: apps, cursor: cursor, selected: selected}) do
    row do
      column(size: 6) do
        panel(title: "Applications") do
          table do
            for {app, i} <- Enum.with_index(apps) do
              table_row(if(cursor.position == i, do: @style_selected, else: [])) do
                table_cell(content: to_string(app))
              end
            end
          end
        end
      end

      column(size: 6) do
        panel(title: app_title(selected)) do
          render_app_details(selected)
        end
      end
    end
  end

  defp render_app_details(nil) do
    label(content: "(No Application)")
  end

  defp render_app_details(%{process_tree: tree}) when is_tuple(tree) do
    tree([to_tree_node(tree)])
  end

  defp render_app_details(_app_without_tree) do
    label(content: "(Application has no master process)")
  end

  defp app_title(%{name: name}), do: to_string(name)
  defp app_title(_other), do: ""

  defp to_tree_node({pid_or_name, children}) do
    tree_node(
      %{content: format_node(pid_or_name)},
      for(child <- children, do: to_tree_node(child))
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
