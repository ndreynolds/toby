defmodule Toby.Components.Port do
  @moduledoc """
  A component for displaying information about ports
  """

  @behaviour Ratatouille.Component.Stateful

  import Ratatouille.Constants, only: [attribute: 1, color: 1, key: 1]
  import Ratatouille.Renderer.View

  alias Toby.Components.{Links, StatusBar}
  alias Toby.Cursor
  alias Toby.Selection
  alias Toby.Stats.Server, as: Stats

  @style_header [
    attributes: [attribute(:bold)]
  ]

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  # The number of rows that make up the application and table frame
  @frame_rows 7

  @impl true
  def handle_event(
        %{ch: ch, key: key},
        %{port_cursor: cursor, ports: ports} = state
      )
      when ch == ?j or key == @arrow_down do
    cursor = Cursor.next(cursor, length(ports))
    {:ok, %{state | port_cursor: cursor}}
  end

  def handle_event(
        %{ch: ch, key: key},
        %{port_cursor: cursor, ports: ports} = state
      )
      when ch == ?k or key == @arrow_up do
    cursor = Cursor.previous(cursor, length(ports))
    {:ok, %{state | port_cursor: cursor}}
  end

  def handle_event(_event, state), do: {:ok, state}

  @impl true
  def handle_tick(state) do
    {:ok,
     Map.merge(state, %{
       port_cursor: state[:port_cursor] || 0,
       ports: Stats.fetch!(:ports)
     })}
  end

  @impl true
  def render(%{ports: all_ports, port_cursor: cursor, window: %{height: height}}) do
    ports = Selection.slice(all_ports, height - @frame_rows, cursor)

    selected = Enum.at(all_ports, cursor)

    status_bar = StatusBar.render(%{selected: :port})

    view(bottom_bar: status_bar) do
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
