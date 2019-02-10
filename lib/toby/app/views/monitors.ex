defmodule Toby.App.Views.Monitors do
  @moduledoc """
  Builds a panel to display process or port links.
  """

  import Ratatouille.View

  def render(monitors, monitored_by) do
    row do
      column size: 12 do
        panel(title: "Monitors (#{length(monitors)})") do
          table do
            for {_type, pid} <- monitors do
              table_row do
                table_cell(content: inspect(pid))
              end
            end
          end
        end

        panel(title: "Monitored By (#{length(monitored_by)})") do
          table do
            for pid <- monitored_by do
              table_row do
                table_cell(content: inspect(pid))
              end
            end
          end
        end
      end
    end
  end
end
