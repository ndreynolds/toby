defmodule Toby.App.Views.Ports do
  @moduledoc """
  Builds a view for displaying information about ports
  """

  import Toby.Util.Formatting, only: [format_bytes: 1]
  import Ratatouille.Constants, only: [attribute: 1, color: 1]
  import Ratatouille.View

  alias Toby.App.Views.{Links, Monitors}
  alias Toby.Util.Selection

  @style_header [
    attributes: [attribute(:bold)]
  ]

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  # The number of rows that make up the application and table frame
  @frame_rows 7

  def render(%{data: %{ports: ports}, cursor: cursor}, window) do
    ports_slice = Selection.slice(ports, window.height - @frame_rows, cursor.position)
    selected = Enum.at(ports, cursor.position)

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

            for port <- ports_slice do
              table_row(if(port == selected, do: @style_selected, else: [])) do
                table_cell(content: inspect(port[:id]))
                table_cell(content: inspect(port[:connected]))
                table_cell(content: to_string(port[:registered_name]))
                table_cell(content: to_string(port[:name]))
                table_cell(content: to_string(port[:slot]))
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
          table_cell(content: to_string(port[:parallelism]))
        end

        table_row do
          table_cell(content: "Locking")
          table_cell(content: to_string(port[:locking]))
        end

        table_row do
          table_cell(content: "Queue Size")
          table_cell(content: format_bytes(port[:queue_size]))
        end

        table_row do
          table_cell(content: "Memory")
          table_cell(content: format_bytes(port[:memory]))
        end
      end

      label(content: "")
      Links.render(port.links)
      Monitors.render(port.monitors, port.monitored_by)
    end
  end

  defp render_port_details(nil) do
    panel(title: "(None selected)", height: :fill)
  end
end
