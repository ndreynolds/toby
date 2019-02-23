defmodule Toby.App.Views.Memory do
  @moduledoc """
  TODO: Builds a view for displaying information about memory usage
  """

  import Ratatouille.View
  import Ratatouille.Constants, only: [attribute: 1]

  @bold attribute(:bold)

  def render(%{data: %{allocators: allocators}}) do
    row do
      column(size: 12) do
        panel title: "Carrier Size (MB)" do
          label(content: "TODO")
        end

        panel title: "Carrier Utilization (%)" do
          label(content: "TODO")
        end

        panel title: "Allocators" do
          table do
            table_row(attributes: [@bold]) do
              table_cell(content: "Allocator Type")
              table_cell(content: "Block size (kB)")
              table_cell(content: "Carrier size (kB)")
            end

            for {alloc, data} <- allocators do
              table_row do
                table_cell(content: to_string(alloc))
                table_cell(content: format_kb(data.block_size))
                table_cell(content: format_kb(data.carrier_size))
              end
            end
          end
        end
      end
    end
  end

  defp format_kb(bytes), do: to_string(:erlang.trunc(bytes / 1024))
end
