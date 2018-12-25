defmodule Toby.Components.Port do
  @moduledoc """
  A component for displaying information about ports
  """

  @behaviour Toby.Component.Stateful

  import ExTermbox.Constants, only: [attribute: 1, color: 1, key: 1]
  import ExTermbox.Renderer.View

  alias ExTermbox.Event

  alias Toby.Components.{Links, StatusBar}
  alias Toby.Stats.Server, as: Stats
  alias Toby.Selection

  @style_header %{
    attributes: [attribute(:bold)]
  }

  @style_selected %{
    color: color(:black),
    background: color(:white)
  }

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  def handle_event(
        %Event{ch: ch, key: key},
        %{port_cursor: cursor, ports: ports} = state
      )
      when ch == ?j or key == @arrow_down do
    {:ok, %{state | port_cursor: min(cursor + 1, length(ports) - 1)}}
  end

  def handle_event(
        %Event{ch: ch, key: key},
        %{port_cursor: cursor} = state
      )
      when ch == ?k or key == @arrow_up do
    {:ok, %{state | port_cursor: max(cursor - 1, 0)}}
  end

  def handle_event(_event, state), do: {:ok, state}

  def tick(state) do
    {:ok,
     Map.merge(state, %{
       port_cursor: state[:port_cursor] || 0,
       ports: Stats.fetch!(:ports)
     })}
  end

  def render(%{ports: all_ports, port_cursor: cursor, window: %{height: height}}) do
    ports = Selection.slice(all_ports, height - 12, cursor)

    selected = Enum.at(all_ports, cursor)

    status_bar = StatusBar.render(%{selected: :port})

    view(bottom_bar: status_bar) do
      row do
        column(size: 8) do
          panel(title: "Ports", height: :fill) do
            table do
              table_row(@style_header, [
                "ID",
                "Connected",
                "Name",
                "Controls",
                "Slot"
              ])

              for port <- ports do
                table_row(
                  if(port == selected, do: @style_selected, else: %{}),
                  [
                    inspect(port.id),
                    inspect(port.connected),
                    "TODO",
                    to_string(port.name),
                    to_string(port.slot)
                  ]
                )
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
        table_row(["Registered Name", to_string(port[:registered_name])])
        table_row(["Connected", inspect(port[:id])])
        table_row(["Slot", to_string(port[:slot])])
        table_row(["Controls", to_string(port[:name])])
        table_row(["Parallelism", "TODO"])
        table_row(["Locking", "TODO"])
        table_row(["Queue Size", "TODO"])
        table_row(["Memory", "TODO"])
      end

      label("")
      Links.render(port.links)
    end
  end

  defp render_port_details(nil) do
    panel(title: "(None selected)", height: :fill)
  end
end
