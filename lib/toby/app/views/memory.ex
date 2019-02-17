defmodule Toby.App.Views.Memory do
  @moduledoc """
  TODO: Builds a view for displaying information about memory usage
  """

  import Ratatouille.View

  def render(_) do
    row do
      column(size: 12) do
        panel title: "Carrier Size (MB)" do
          label(content: "TODO")
        end

        panel title: "Carrier Utilization (%)" do
          label(content: "TODO")
        end
      end
    end
  end
end
