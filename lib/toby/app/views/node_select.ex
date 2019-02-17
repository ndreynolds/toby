defmodule Toby.App.Views.NodeSelect do
  @moduledoc """
  Builds a panel for managing the selected Erlang node.

  TODO: Support changing selection
  """

  import Ratatouille.View

  def render(:not_loaded) do
    panel(title: "Node Selection (<ESC> to close)", height: :fill) do
      label(content: "Loading...")
    end
  end

  def render(%{
        current: current,
        cookie: cookie,
        connected_nodes: connected,
        visible_nodes: visible
      }) do
    panel(title: "Node Selection (<ESC> to close)", height: :fill) do
      panel(title: "Current") do
        table do
          table_row do
            table_cell(content: "Name")
            table_cell(content: to_string(current))
          end

          table_row do
            table_cell(content: "Cookie")
            table_cell(content: to_string(cookie))
          end
        end
      end

      row do
        column(size: 6) do
          panel(title: "Connected Nodes") do
            table do
              for node <- connected do
                table_row do
                  table_cell(content: to_string(node))
                end
              end
            end
          end
        end

        column(size: 6) do
          panel(title: "Visible Nodes") do
            table do
              for {node, port} <- visible do
                table_row do
                  table_cell(content: to_string(node))
                  table_cell(content: to_string(port))
                end
              end
            end
          end
        end
      end
    end
  end
end
