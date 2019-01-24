defmodule Toby.Components.System do
  @moduledoc """
  A component that displays summarized information about the Erlang VM.
  """

  @behaviour Ratatouille.Component.Stateful

  import Ratatouille.View
  import Toby.Formatting

  alias Toby.Components.StatusBar
  alias Toby.Stats.Server, as: Stats

  @impl true
  def handle_event(_event, state), do: {:ok, state}

  @impl true
  def handle_tick(_state) do
    {:ok,
     %{
       cpu: Stats.fetch!(:cpu),
       limits: Stats.fetch!(:limits),
       memory: Stats.fetch!(:memory),
       statistics: Stats.fetch!(:statistics),
       system: Stats.fetch!(:system)
     }}
  end

  @impl true
  def render(%{
        cpu: cpu,
        limits: limits,
        memory: memory,
        statistics: statistics,
        system: system
      }) do
    status_bar = StatusBar.render(%{selected: :system})

    view(bottom_bar: status_bar) do
      row do
        column(size: 6) do
          panel(title: "System and Architecture") do
            table do
              table_row do
                table_cell(content: "System Version:")
                table_cell(content: to_string(system.otp_release))
              end

              table_row do
                table_cell(content: "ERTS Version:")
                table_cell(content: to_string(system.erts_version))
              end

              table_row do
                table_cell(content: "Compiled for:")
                table_cell(content: to_string(system.compiled_for))
              end

              table_row do
                table_cell(content: "Emulator Wordsize:")
                table_cell(content: to_string(system.emulator_wordsize))
              end

              table_row do
                table_cell(content: "Process Wordsize:")
                table_cell(content: to_string(system.process_wordsize))
              end

              table_row do
                table_cell(content: "SMP Support:")
                table_cell(content: to_string(system.smp_support?))
              end

              table_row do
                table_cell(content: "Thread Support:")
                table_cell(content: to_string(system.thread_support?))
              end

              table_row do
                table_cell(content: "Async thread pool size:")
                table_cell(content: to_string(system.async_thread_pool_size))
              end
            end
          end
        end

        column(size: 6) do
          panel(title: "Memory Usage") do
            table do
              table_row do
                table_cell(content: "Total")
                table_cell(content: format_bytes(memory.total))
              end

              table_row do
                table_cell(content: "Processes")
                table_cell(content: format_bytes(memory.processes))
              end

              table_row do
                table_cell(content: "Processes (used)")
                table_cell(content: format_bytes(memory.processes_used))
              end

              table_row do
                table_cell(content: "System")
                table_cell(content: format_bytes(memory.system))
              end

              table_row do
                table_cell(content: "Atoms")
                table_cell(content: format_bytes(memory.atom))
              end

              table_row do
                table_cell(content: "Atoms (used)")
                table_cell(content: format_bytes(memory.atom_used))
              end

              table_row do
                table_cell(content: "Binaries")
                table_cell(content: format_bytes(memory.binary))
              end

              table_row do
                table_cell(content: "Code")
                table_cell(content: format_bytes(memory.code))
              end

              table_row do
                table_cell(content: "ETS")
                table_cell(content: format_bytes(memory.ets))
              end
            end
          end
        end
      end

      row do
        column(size: 6) do
          panel(title: "CPUs & Threads") do
            table do
              table_row do
                table_cell(content: "Logical CPUs:")
                table_cell(content: to_string(cpu.logical_cpus))
              end

              table_row do
                table_cell(content: "Online Logical CPUs:")
                table_cell(content: to_string(cpu.online_logical_cpus))
              end

              table_row do
                table_cell(content: "Available Logical CPUs:")
                table_cell(content: to_string(cpu.available_logical_cpus))
              end

              table_row do
                table_cell(content: "Schedulers:")
                table_cell(content: to_string(cpu.schedulers))
              end

              table_row do
                table_cell(content: "Online schedulers:")
                table_cell(content: to_string(cpu.online_schedulers))
              end

              table_row do
                table_cell(content: "Available schedulers:")
                table_cell(content: to_string(cpu.available_schedulers))
              end
            end
          end
        end

        column(size: 6) do
          panel(title: "Statistics") do
            table do
              table_row do
                table_cell(content: "Uptime:")
                table_cell(content: format_ms(statistics.uptime_ms))
              end

              table_row do
                table_cell(content: "Run Queue:")
                table_cell(content: to_string(statistics.run_queue))
              end

              table_row do
                table_cell(content: "IO Input:")
                table_cell(content: format_bytes(statistics.io_input_bytes))
              end

              table_row do
                table_cell(content: "IO Output:")
                table_cell(content: format_bytes(statistics.io_output_bytes))
              end
            end
          end
        end
      end

      row do
        column(size: 12) do
          panel(title: "System statistics / limit") do
            table do
              table_row do
                table_cell(content: "Atoms:")
                table_cell(content: format_limit(limits.atoms))
              end

              table_row do
                table_cell(content: "Processes:")
                table_cell(content: format_limit(limits.procs))
              end

              table_row do
                table_cell(content: "Ports:")
                table_cell(content: format_limit(limits.ports))
              end

              table_row do
                table_cell(content: "ETS:")
                table_cell(content: format_limit(limits.ets))
              end

              table_row do
                table_cell(content: "Distribution buffer busy limit:")
                table_cell(content: to_string(limits.dist_buffer_busy))
              end
            end
          end
        end
      end
    end
  end

  defp format_limit(%{count: count, limit: limit, percent_used: percent}) do
    "#{count} / #{limit} (#{percent}% used)"
  end
end
