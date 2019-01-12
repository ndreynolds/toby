defmodule Toby.Components.Process do
  @moduledoc """
  A component for displaying information about processes
  """

  @behaviour Toby.Component.Stateful

  import ExTermbox.Constants, only: [attribute: 1, color: 1, key: 1]
  import ExTermbox.Renderer.View

  import Toby.Formatting, only: [format_func: 1]

  alias ExTermbox.Event

  alias Toby.Components.{Links, StatusBar}
  alias Toby.Selection
  alias Toby.Stats.Server, as: Stats

  @style_header [
    attributes: [attribute(:bold)]
  ]

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  def handle_event(
        %Event{ch: ch, key: key},
        %{process_cursor: cursor, processes: processes} = state
      )
      when ch == ?j or key == @arrow_down do
    {:ok, %{state | process_cursor: min(cursor + 1, length(processes) - 1)}}
  end

  def handle_event(
        %Event{ch: ch, key: key},
        %{process_cursor: cursor} = state
      )
      when ch == ?k or key == @arrow_up do
    {:ok, %{state | process_cursor: max(cursor - 1, 0)}}
  end

  def handle_event(_event, state), do: {:ok, state}

  def tick(state) do
    {:ok,
     Map.merge(state, %{
       process_cursor: state[:process_cursor] || 0,
       processes: Stats.fetch!(:processes)
     })}
  end

  def render(%{processes: all_processes, process_cursor: cursor, window: %{height: height}}) do
    processes = Selection.slice(all_processes, height - 12, cursor)

    selected = Enum.at(all_processes, cursor)

    status_bar = StatusBar.render(%{selected: :process})

    view(bottom_bar: status_bar) do
      row do
        column(size: 8) do
          panel(title: "Processes", height: :fill) do
            table do
              table_row(
                Keyword.merge(
                  @style_header,
                  values: [
                    "PID",
                    "Name or Initial Func",
                    "Reds",
                    "Memory",
                    "MsgQ",
                    "Current Function"
                  ]
                )
              )

              for proc <- processes do
                table_row(
                  Keyword.merge(
                    if(proc == selected, do: @style_selected, else: []),
                    values: [
                      inspect(proc.pid),
                      name_or_initial_func(proc),
                      to_string(proc.reductions),
                      inspect(proc.memory),
                      to_string(proc.message_queue_len),
                      format_func(proc.current_function)
                    ]
                  )
                )
              end
            end
          end
        end

        column(size: 4) do
          render_process_details(selected)
        end
      end
    end
  end

  defp render_process_details(%{pid: pid} = process) do
    title = inspect(pid) <> " " <> name_or_initial_func(process)

    panel(title: title, height: :fill) do
      table do
        table_row(values: ["Initial Call", format_func(process.initial_call)])
        table_row(values: ["Current Function", format_func(process.current_function)])
        table_row(values: ["Registered Name", to_string(process[:registered_name])])
        table_row(values: ["Status", to_string(process[:status])])
        table_row(values: ["Message Queue Len", to_string(process[:message_queue_len])])
        table_row(values: ["Group Leader", inspect(process[:group_leader])])
        table_row(values: ["Priority", to_string(process[:priority])])
        table_row(values: ["Trap Exit", to_string(process[:trap_exit])])
        table_row(values: ["Reductions", to_string(process[:reductions])])
        table_row(values: ["Error Handler", to_string(process[:error_handler])])
        table_row(values: ["Trace", to_string(process[:trace])])
      end

      label(content: "")
      Links.render(process.links)
    end
  end

  defp render_process_details(nil) do
    panel(title: "(None selected)", height: :fill)
  end

  defp name_or_initial_func(process) do
    process
    |> Map.get_lazy(:registered_name, fn ->
      format_func(process.initial_call)
    end)
    |> to_string()
  end
end
