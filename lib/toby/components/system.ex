defmodule Toby.Components.System do
  @moduledoc """
  A component that displays summarized information about the Erlang VM.
  """

  @behaviour Ratatouille.Component.Stateful

  import Ratatouille.Renderer.View
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
              table_row(values: ["System Version:", to_string(system.otp_release)])
              table_row(values: ["ERTS Version:", to_string(system.erts_version)])
              table_row(values: ["Compiled for:", to_string(system.compiled_for)])
              table_row(values: ["Emulator Wordsize:", to_string(system.emulator_wordsize)])
              table_row(values: ["Process Wordsize:", to_string(system.process_wordsize)])
              table_row(values: ["SMP Support:", to_string(system.smp_support?)])
              table_row(values: ["Thread Support:", to_string(system.thread_support?)])

              table_row(
                values: ["Async thread pool size:", to_string(system.async_thread_pool_size)]
              )
            end
          end
        end

        column(size: 6) do
          panel(title: "Memory Usage") do
            table do
              table_row(values: ["Total", format_bytes(memory.total)])
              table_row(values: ["Processes", format_bytes(memory.processes)])
              table_row(values: ["Processes (used)", format_bytes(memory.processes_used)])
              table_row(values: ["System", format_bytes(memory.system)])
              table_row(values: ["Atoms", format_bytes(memory.atom)])
              table_row(values: ["Atoms (used)", format_bytes(memory.atom_used)])
              table_row(values: ["Binaries", format_bytes(memory.binary)])
              table_row(values: ["Code", format_bytes(memory.code)])
              table_row(values: ["ETS", format_bytes(memory.ets)])
            end
          end
        end
      end

      row do
        column(size: 6) do
          panel(title: "CPUs & Threads") do
            table do
              table_row(values: ["Logical CPUs:", to_string(cpu.logical_cpus)])
              table_row(values: ["Online Logical CPUs:", to_string(cpu.online_logical_cpus)])

              table_row(
                values: ["Available Logical CPUs:", to_string(cpu.available_logical_cpus)]
              )

              table_row(values: ["Schedulers:", to_string(cpu.schedulers)])
              table_row(values: ["Online schedulers:", to_string(cpu.online_schedulers)])
              table_row(values: ["Available schedulers:", to_string(cpu.available_schedulers)])
            end
          end
        end

        column(size: 6) do
          panel(title: "Statistics") do
            table do
              table_row(values: ["Uptime:", format_ms(statistics.uptime_ms)])
              table_row(values: ["Run Queue:", to_string(statistics.run_queue)])
              table_row(values: ["IO Input:", format_bytes(statistics.io_input_bytes)])
              table_row(values: ["IO Output:", format_bytes(statistics.io_output_bytes)])
            end
          end
        end
      end

      row do
        column(size: 12) do
          panel(title: "System statistics / limit") do
            table do
              table_row(
                values: [
                  "Atoms:",
                  "#{limits.atoms.count} / #{limits.atoms.limit} (#{limits.atoms.percent_used}% used)"
                ]
              )

              table_row(
                values: [
                  "Processes:",
                  "#{limits.procs.count} / #{limits.procs.limit} (#{limits.procs.percent_used}% used)"
                ]
              )

              table_row(
                values: [
                  "Ports:",
                  "#{limits.ports.count} / #{limits.ports.limit} (#{limits.ports.percent_used}% used)"
                ]
              )

              table_row(
                values: [
                  "ETS:",
                  "#{limits.ets.count} / #{limits.ets.limit} (#{limits.ets.percent_used}% used)"
                ]
              )

              table_row(
                values: ["Distribution buffer busy limit:", to_string(limits.dist_buffer_busy)]
              )
            end
          end
        end
      end
    end
  end
end
