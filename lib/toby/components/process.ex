defmodule Toby.Components.Process do
  @moduledoc """
  A component for displaying information about processes
  """

  @behaviour Toby.Component

  import ExTermbox.Constants, only: [attribute: 1, color: 1, key: 1]
  import ExTermbox.Renderer.View

  import Toby.Formatting, only: [format_func: 1]

  alias ExTermbox.Event

  alias Toby.Components.StatusBar
  alias Toby.Stats.Server, as: Stats

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
        %{selected_index: cursor, processes: processes} = state
      )
      when ch == ?j or key == @arrow_down do
    {:ok, %{state | selected_index: min(cursor + 1, length(processes) - 1)}}
  end

  def handle_event(
        %Event{ch: ch, key: key},
        %{selected_index: cursor} = state
      )
      when ch == ?k or key == @arrow_up do
    {:ok, %{state | selected_index: max(cursor - 1, 0)}}
  end

  def handle_event(_event, state), do: {:ok, state}

  def tick(state) do
    {:ok,
     Map.merge(state, %{
       selected_index: state[:selected_index] || 0,
       processes: Stats.fetch(:processes)
     })}
  end

  def render(%{processes: processes, selected_index: selected_idx, window: %{height: height}}) do
    processes =
      processes
      |> Enum.with_index()
      |> Enum.map(fn {proc, idx} ->
        Map.merge(proc, %{selected: idx == selected_idx})
      end)
      |> slice(height - 12, selected_idx)

    selected = Enum.find(processes, fn proc -> proc.selected end)

    status_bar = StatusBar.render(%{selected: :process})

    view(bottom_bar: status_bar) do
      row do
        column(size: 8) do
          panel(title: "Processes", height: :fill) do
            table do
              header_row()
              for proc <- processes, do: process_row(proc)
            end
          end
        end

        column(size: 4) do
          process_overview(selected)
        end
      end
    end
  end

  defp process_overview(%{pid: pid} = process) do
    title = inspect(pid) <> " " <> name_or_initial_func(process)

    panel(title: title, height: :fill) do
      table do
        table_row(["Initial Call", format_func(process.initial_call)])
        table_row(["Current Function", format_func(process.current_function)])
        table_row(["Registered Name", to_string(process[:registered_name])])
        table_row(["Status", to_string(process[:status])])
        table_row(["Message Queue Len", to_string(process[:message_queue_len])])
        table_row(["Group Leader", inspect(process[:group_leader])])
        table_row(["Priority", to_string(process[:priority])])
        table_row(["Trap Exit", to_string(process[:trap_exit])])
        table_row(["Reductions", to_string(process[:reductions])])
        table_row(["Error Handler", to_string(process[:error_handler])])
        table_row(["Trace", to_string(process[:trace])])
      end

      label("")
      label("Links (#{length(process.links)})")
      process_links(process)
    end
  end

  defp process_overview(nil) do
    panel(title: "(None selected)", height: :fill) do
    end
  end

  defp process_links(%{links: links}) do
    table do
      for link <- links, do: table_row([inspect(link)])
    end
  end

  defp header_row do
    table_row(@style_header, [
      "PID",
      "Name or Initial Func",
      "Reds",
      "Memory",
      "MsgQ",
      "Current Function"
    ])
  end

  defp process_row(process) do
    table_row(
      if(process.selected, do: @style_selected, else: %{}),
      [
        inspect(process.pid),
        name_or_initial_func(process),
        to_string(process.reductions),
        inspect(process.memory),
        to_string(process.message_queue_len),
        format_func(process.current_function)
      ]
    )
  end

  defp slice(processes, n, idx) when idx < n do
    Enum.take(processes, n)
  end

  defp slice(processes, n, idx) do
    processes
    |> Enum.drop(idx - n + 1)
    |> Enum.take(n)
  end

  defp name_or_initial_func(process) do
    process
    |> Map.get_lazy(:registered_name, fn ->
      format_func(process.initial_call)
    end)
    |> to_string()
  end
end
