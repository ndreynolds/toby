defmodule Toby.App.Views.Memory do
  @moduledoc """
  TODO: Builds a view for displaying information about memory usage
  """

  alias Toby.Util.Selection

  import Ratatouille.View
  import Ratatouille.Constants, only: [attribute: 1, color: 1]

  @bold attribute(:bold)

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def render(%{
        data: %{
          allocators: allocators,
          allocator_names: allocator_names,
          allocation_history: history
        },
        cursor_y: %{position: position}
      }) do
    opts = Enum.with_index(allocator_names)
    visible_opts = Selection.slice(opts, 10, position)
    selected_opt = Enum.at(allocator_names, position)

    series = for val <- history, do: val[selected_opt]

    row do
      column(size: 12) do
        panel title: "Carriers" do
          row do
            column(size: 8) do
              label(content: "Size (MB)", attributes: [attribute(:bold)])
              chart(type: :line, series: fill_series(series), height: 8)

              label(content: "Utilization (%) (TODO)", attributes: [attribute(:bold)])
              chart(type: :line, series: fill_series(series), height: 8)
            end

            column(size: 4) do
              panel title: "Selection", height: 14 do
                table do
                  for {name, idx} <- visible_opts do
                    table_row(if(idx == position, do: @style_selected, else: [])) do
                      table_cell(content: to_string(name))
                    end
                  end
                end
              end
            end
          end
        end

        panel title: "Allocators" do
          table do
            table_row(attributes: [@bold]) do
              table_cell(content: "Allocator Type")
              table_cell(content: "Block size (kB)")
              table_cell(content: "Carrier size (kB)")
              table_cell(content: "Max Carrier size (kB)")
            end

            for {alloc, data} <- allocators do
              table_row do
                table_cell(content: to_string(alloc))
                table_cell(content: format_kb(data.block_size))
                table_cell(content: format_kb(data.carrier_size))
                table_cell(content: "TODO")
              end
            end
          end
        end
      end
    end
  end

  defp format_kb(bytes), do: to_string(:erlang.trunc(bytes / 1024))

  defp fill_series(series) when length(series) >= 60, do: series
  defp fill_series(series), do: List.duplicate(0, 60 - length(series)) ++ series
end
