defmodule Toby.Views.System do
  import Toby.Formatting
  import ExTermbox.Renderer.View

  alias Toby.Views.StatusBar

  def render(%{system: system, memory: memory}) do
    view do
      columned_layout do
        panel(title: "System and Architecture") do
          table do
            table_row(["System Version:", to_string(system.otp_release)])
            table_row(["ERTS Version:", to_string(system.erts_version)])
            table_row(["Compiled for:", to_string(system.compiled_for)])
            table_row(["Emulator Wordsize:", "TODO"])
            table_row(["Process Wordsize:", "TODO"])
            table_row(["SMP Support:", to_string(system.smp_support?)])
            table_row(["Thread Support:", "TODO"])
            table_row(["Async thread pool size:", "TODO"])
          end
        end

        panel(title: "Memory Usage") do
          table do
            table_row(["Total", humanize_bytes(memory.total)])
            table_row(["Processes", humanize_bytes(memory.processes)])
            table_row(["Processes (Used)", humanize_bytes(memory.processes_used)])
            table_row(["System", humanize_bytes(memory.system)])
            table_row(["Atoms", humanize_bytes(memory.atom)])
            table_row(["Atoms (Used)", humanize_bytes(memory.atom_used)])
            table_row(["Binary", humanize_bytes(memory.binary)])
            table_row(["Code", humanize_bytes(memory.code)])
            table_row(["ETS", humanize_bytes(memory.ets)])
          end
        end
      end

      columned_layout do
        panel(title: "CPUs & Threads") do
          table do
            table_row(["Logical CPUs:", "TODO"])
            table_row(["Online Logical CPUs:", "TODO"])
            table_row(["Available Logical CPUs:", "TODO"])
            table_row(["Schedulers:", "TODO"])
            table_row(["Online Schedulers:", "TODO"])
            table_row(["Available Schedulers:", "TODO"])
          end
        end

        panel(title: "Statistics") do
          table do
            table_row(["Uptime:", "TODO"])
            table_row(["Run Queue:", "TODO"])
            table_row(["IO Input:", "TODO"])
            table_row(["IO Output:", "TODO"])
          end
        end
      end

      panel(title: "System Statistics / Limit") do
        table do
          table_row(["Atoms:", "TODO"])
          table_row(["Processes:", "TODO"])
          table_row(["Ports:", "TODO"])
          table_row(["ETS:", "TODO"])
          table_row(["Distribution buffer busy limit:", "TODO"])
        end
      end

      StatusBar.render(%{selected: "System"})
    end
  end
end
