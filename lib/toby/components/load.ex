defmodule Toby.Components.Load do
  @moduledoc """
  TODO: A component for displaying information about system load
  """

  @behaviour Ratatouille.Component.Stateful

  import Ratatouille.Constants, only: [color: 1, key: 1]
  import Ratatouille.Renderer.View

  alias Toby.Components.StatusBar
  alias Toby.Cursor
  alias Toby.Selection
  alias Toby.Stats.Server, as: Stats

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  @impl true
  def handle_event(
        %{ch: ch, key: key},
        %{load_cursor: cursor, utilization_opts: opts} = state
      )
      when ch == ?j or key == @arrow_down do
    cursor = Cursor.next(cursor, length(opts))
    {:ok, %{state | load_cursor: cursor}}
  end

  def handle_event(
        %{ch: ch, key: key},
        %{load_cursor: cursor, utilization_opts: opts} = state
      )
      when ch == ?k or key == @arrow_up do
    cursor = Cursor.previous(cursor, length(opts))
    {:ok, %{state | load_cursor: cursor}}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

  @impl true
  def handle_tick(state) do
    %{schedulers: scheduler_count} = Stats.fetch!(:cpu)

    {:ok,
     Map.merge(state, %{
       load_cursor: state[:load_cursor] || 0,
       utilization: Stats.fetch!(:historical_scheduler_utilization),
       utilization_opts: build_utilization_opts(scheduler_count),
       memory: Stats.fetch!(:historical_memory),
       io: Stats.fetch!(:historical_io)
     })}
  end

  @impl true
  def render(%{
        utilization: utilization,
        utilization_opts: all_utilization_opts,
        memory: memory,
        io: io,
        load_cursor: cursor
      }) do
    # Find the selected utilization series
    utilization_opts = Selection.slice(all_utilization_opts, 6, cursor)
    {{_label, key}, _idx} = Enum.at(all_utilization_opts, cursor)
    utilization_series = for sample <- utilization, do: sample[key]

    status_bar = StatusBar.render(%{selected: :load})

    # TODO: 0 prefixes on series are a temporary workaround for a plotting bug
    # when all values are the same

    view(bottom_bar: status_bar) do
      panel title: "Scheduler Utilization (%)" do
        row do
          column size: 9 do
            chart(type: :line, series: [0 | utilization_series], height: 10)
          end

          column size: 3 do
            panel title: "Selection", height: 10 do
              table do
                for {{label, _key}, idx} <- utilization_opts do
                  table_row(if(idx == cursor, do: @style_selected, else: [])) do
                    table_cell(content: label)
                  end
                end
              end
            end
          end
        end
      end

      row do
        column size: 6 do
          panel title: "Memory Usage (MB)" do
            chart(type: :line, series: [0 | memory], height: 10)
          end
        end

        column size: 6 do
          panel title: "IO Usage (B)" do
            chart(type: :line, series: [0 | io], height: 10)
          end
        end
      end
    end
  end

  defp build_utilization_opts(scheduler_count) do
    scheduler_opts = for i <- 1..scheduler_count, do: {"Scheduler #{i}", i}

    Enum.with_index([{"Total", :total} | scheduler_opts])
  end
end
