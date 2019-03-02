defmodule Toby.App.Views.Tables do
  @moduledoc """
  Builds a view for displaying information about ETS tables

  TODO: Show DETS & Mnesia tables
  """

  alias Toby.Util.Selection

  import Toby.Util.Formatting, only: [format_bytes: 1]
  import Ratatouille.View
  import Ratatouille.Constants, only: [attribute: 1, color: 1]

  @frame_rows 7

  @bold attribute(:bold)

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def render(%{data: %{tables: tables}, cursor: cursor}, window) do
    tables_slice = Selection.slice(tables, window.height - @frame_rows, cursor.position)

    selected = Enum.at(tables, cursor.position)

    row do
      column(size: 8) do
        panel title: "Tables (ETS)", height: :fill do
          table do
            table_row(attributes: [@bold]) do
              table_cell(content: "Name")
              table_cell(content: "Objects")
              table_cell(content: "Size")
              table_cell(content: "Owner PID")
              table_cell(content: "Owner Name")
              table_cell(content: "Table ID")
            end

            for tab <- tables_slice do
              table_row(if(tab == selected, do: @style_selected, else: [])) do
                table_cell(content: to_string(tab[:name]))
                table_cell(content: to_string(tab[:size]))
                table_cell(content: format_bytes(tab[:memory]))
                table_cell(content: inspect(tab[:owner]))
                table_cell(content: to_string(tab[:owner_name]))
                table_cell(content: inspect(tab[:id]))
              end
            end
          end
        end
      end

      column(size: 4) do
        render_table_details(selected)
      end
    end
  end

  defp render_table_details(tab) do
    panel title: to_string(tab[:name]), height: :fill do
      label do
        text(attributes: [@bold], content: "Identification & Owner")
      end

      table do
        table_row do
          table_cell(content: "Name")
          table_cell(content: to_string(tab[:name]))
        end

        table_row do
          table_cell(content: "ID")
          table_cell(content: inspect(tab[:id]))
        end

        table_row do
          table_cell(content: "Named table")
          table_cell(content: to_string(tab[:named_table]))
        end

        table_row do
          table_cell(content: "Owner")
          table_cell(content: inspect(tab[:owner]))
        end

        table_row do
          table_cell(content: "Owner name")
          table_cell(content: to_string(tab[:owner_name]))
        end

        table_row do
          table_cell(content: "Heir")
          table_cell(content: to_string(tab[:heir]))
        end

        table_row do
          table_cell(content: "Node")
          table_cell(content: to_string(tab[:node]))
        end
      end

      label do
        text(attributes: [@bold], content: "Settings")
      end

      table do
        table_row do
          table_cell(content: "Source")
          table_cell(content: to_string(tab[:source]))
        end

        table_row do
          table_cell(content: "Key position")
          table_cell(content: to_string(tab[:keypos]))
        end

        table_row do
          table_cell(content: "Table type")
          table_cell(content: to_string(tab[:type]))
        end

        table_row do
          table_cell(content: "Protection mode")
          table_cell(content: to_string(tab[:protection]))
        end
      end

      label do
        text(attributes: [@bold], content: "Memory Usage")
      end

      table do
        table_row do
          table_cell(content: "Number of objects")
          table_cell(content: to_string(tab[:size]))
        end

        table_row do
          table_cell(content: "Memory allocated")
          table_cell(content: format_bytes(tab[:memory]))
        end

        table_row do
          table_cell(content: "Compressed")
          table_cell(content: to_string(tab[:compressed]))
        end
      end
    end
  end
end
