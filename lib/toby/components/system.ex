defmodule Toby.Components.System do
  @moduledoc """
  A component that displays summarized information about the Erlang VM.
  """

  @behaviour Toby.Component.Stateful

  import Toby.Formatting
  import ExTermbox.Renderer.View

  alias Toby.Components.StatusBar
  alias Toby.Stats.Server, as: Stats

  def handle_event(_event, state), do: {:ok, state}

  def tick(_state) do
    {:ok,
     %{
       cpu: Stats.fetch!(:cpu),
       limits: Stats.fetch!(:limits),
       memory: Stats.fetch!(:memory),
       statistics: Stats.fetch!(:statistics),
       system: Stats.fetch!(:system)
     }}
  end

  def render(%{cpu: cpu, limits: limits, memory: memory, statistics: statistics, system: system}) do
    status_bar = StatusBar.render(%{selected: :system})

    view(bottom_bar: status_bar) do
      row do
        column(size: 6) do
          panel(title: "System and Architecture") do
            table do
              table_row(["System Version:", to_string(system.otp_release)])
              table_row(["ERTS Version:", to_string(system.erts_version)])
              table_row(["Compiled for:", to_string(system.compiled_for)])
              table_row(["Emulator Wordsize:", to_string(system.emulator_wordsize)])
              table_row(["Process Wordsize:", to_string(system.process_wordsize)])
              table_row(["SMP Support:", to_string(system.smp_support?)])
              table_row(["Thread Support:", to_string(system.thread_support?)])
              table_row(["Async thread pool size:", to_string(system.async_thread_pool_size)])
            end
          end
        end

        column(size: 6) do
          panel(title: "Memory Usage") do
            table do
              table_row(["Total", humanize_bytes(memory.total)])
              table_row(["Processes", humanize_bytes(memory.processes)])
              table_row(["Processes (used)", humanize_bytes(memory.processes_used)])
              table_row(["System", humanize_bytes(memory.system)])
              table_row(["Atoms", humanize_bytes(memory.atom)])
              table_row(["Atoms (used)", humanize_bytes(memory.atom_used)])
              table_row(["Binaries", humanize_bytes(memory.binary)])
              table_row(["Code", humanize_bytes(memory.code)])
              table_row(["ETS", humanize_bytes(memory.ets)])
            end
          end
        end
      end

      row do
        column(size: 6) do
          panel(title: "CPUs & Threads") do
            table do
              table_row(["Logical CPUs:", to_string(cpu.logical_cpus)])
              table_row(["Online Logical CPUs:", to_string(cpu.online_logical_cpus)])
              table_row(["Available Logical CPUs:", to_string(cpu.available_logical_cpus)])
              table_row(["Schedulers:", to_string(cpu.schedulers)])
              table_row(["Online schedulers:", to_string(cpu.online_schedulers)])
              table_row(["Available schedulers:", to_string(cpu.available_schedulers)])
            end
          end
        end

        column(size: 6) do
          panel(title: "Statistics") do
            table do
              table_row(["Uptime:", humanize_relative_time(statistics.uptime_ms)])
              table_row(["Run Queue:", to_string(statistics.run_queue)])
              table_row(["IO Input:", humanize_bytes(statistics.io_input_bytes)])
              table_row(["IO Output:", humanize_bytes(statistics.io_output_bytes)])
            end
          end
        end
      end

      row do
        column(size: 12) do
          panel(title: "System statistics / limit") do
            table do
              table_row([
                "Atoms:",
                "#{limits.atoms.count} / #{limits.atoms.limit} (#{limits.atoms.percent_used}% used)"
              ])

              table_row([
                "Processes:",
                "#{limits.procs.count} / #{limits.procs.limit} (#{limits.procs.percent_used}% used)"
              ])

              table_row([
                "Ports:",
                "#{limits.ports.count} / #{limits.ports.limit} (#{limits.ports.percent_used}% used)"
              ])

              table_row([
                "ETS:",
                "#{limits.ets.count} / #{limits.ets.limit} (#{limits.ets.percent_used}% used)"
              ])

              table_row(["Distribution buffer busy limit:", to_string(limits.dist_buffer_busy)])
            end
          end
        end
      end
    end
  end
end
