defmodule Toby.Views.Ports do
  @moduledoc """
  Builds a view for displaying information about ports
  """

  import Ratatouille.Constants, only: [attribute: 1, color: 1]
  import Ratatouille.View

  alias Toby.Views.Links
  alias Toby.Selection

  @style_header [
    attributes: [attribute(:bold)]
  ]

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  # The number of rows that make up the application and table frame
  @frame_rows 7

  def render(%{ports: all_ports, cursor: cursor}, window) do
    ports = Selection.slice(all_ports, window.height - @frame_rows, cursor)
    selected = Enum.at(all_ports, cursor)

    row do
      column(size: 8) do
        panel(title: "Ports", height: :fill) do
          table do
            table_row(@style_header) do
              table_cell(content: "ID")
              table_cell(content: "Connected")
              table_cell(content: "Name")
              table_cell(content: "Controls")
              table_cell(content: "Slot")
            end

            for port <- ports do
              table_row(if(port == selected, do: @style_selected, else: [])) do
                table_cell(content: inspect(port.id))
                table_cell(content: inspect(port.connected))
                table_cell(content: "TODO")
                table_cell(content: to_string(port.name))
                table_cell(content: to_string(port.slot))
              end
            end
          end
        end
      end

      column(size: 4) do
        render_port_details(selected)
      end
    end
  end

  defp render_port_details(%{id: id} = port) do
    panel(title: inspect(id), height: :fill) do
      table do
        table_row do
          table_cell(content: "Registered Name")
          table_cell(content: to_string(port[:registered_name]))
        end

        table_row do
          table_cell(content: "Connected")
          table_cell(content: inspect(port[:id]))
        end

        table_row do
          table_cell(content: "Slot")
          table_cell(content: to_string(port[:slot]))
        end

        table_row do
          table_cell(content: "Controls")
          table_cell(content: to_string(port[:name]))
        end

        table_row do
          table_cell(content: "Parallelism")
          table_cell(content: "TODO")
        end

        table_row do
          table_cell(content: "Locking")
          table_cell(content: "TODO")
        end

        table_row do
          table_cell(content: "Queue Size")
          table_cell(content: "TODO")
        end

        table_row do
          table_cell(content: "Memory")
          table_cell(content: "TODO")
        end
      end

      label(content: "")
      Links.render(port.links)
    end
  end

  defp render_port_details(nil) do
    panel(title: "(None selected)", height: :fill)
  end
end
