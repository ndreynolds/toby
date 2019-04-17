defmodule Toby.App.Views.Load do
  @moduledoc """
  Builds a view for displaying information about system load
  """

  import Ratatouille.Constants, only: [color: 1]
  import Ratatouille.View

  alias Toby.Util.Selection

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def render(%{
        data: %{
          utilization: utilization,
          scheduler_count: scheduler_count,
          memory: memory,
          io: io
        },
        cursor_y: %{position: position}
      })
      when position <= 8 do
    util_opts = build_utilization_opts(scheduler_count)
    visible_util_opts = Selection.slice(util_opts, 6, position)
    util_series = selected_utilization_series(utilization, util_opts, position)

    row do
      column size: 12 do
        panel title: "Scheduler Utilization (%)" do
          row do
            column size: 9 do
              chart(type: :line, series: fill_series(util_series), height: 10)
            end

            column size: 3 do
              panel title: "Selection", height: 10 do
                table do
                  for {{label, _key}, idx} <- visible_util_opts do
                    table_row(if(idx == position, do: @style_selected, else: [])) do
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
            panel title: "Memory Usage (MB)", height: 15 do
              chart(type: :line, series: fill_series(memory), height: 10)
            end
          end

          column size: 6 do
            panel title: "IO Usage (B)", height: 15 do
              chart(type: :line, series: fill_series(io), height: 10)
            end
          end
        end
      end
    end
  end

  defp selected_utilization_series(utilization, opts, cursor) do
    # Find the selected utilization series
    {{_label, key}, _idx} = Enum.at(opts, cursor)
    for sample <- utilization, do: sample[key]
  end

  defp build_utilization_opts(scheduler_count) do
    scheduler_opts = for i <- 1..scheduler_count, do: {"Scheduler #{i}", i}

    Enum.with_index([{"Total", :total} | scheduler_opts])
  end

  defp fill_series(series) when length(series) >= 60, do: series
  defp fill_series(series), do: List.duplicate(0, 60 - length(series)) ++ series
end
