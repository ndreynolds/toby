defmodule Toby.App.Views.Memory do
  @moduledoc """
  TODO: Builds a view for displaying information about memory usage
  """

  import Ratatouille.View
  import Ratatouille.Constants, only: [attribute: 1]

  @bold attribute(:bold)

  def render(%{data: %{allocators: allocators, allocation_history: history}}) do
    series_names = Map.keys(allocators)

    row do
      column(size: 12) do
        row do
          column(size: 8) do
            panel title: "Carrier Size (MB)" do
              chart(type: :line, series: fill_series(history), height: 8)
            end

            panel title: "Carrier Utilization (%) (TODO)" do
              chart(type: :line, series: fill_series(history), height: 8)
            end
          end

          column(size: 4) do
            panel title: "Selection" do
              table do
                for name <- series_names do
                  table_row do
                    table_cell(content: to_string(name))
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
