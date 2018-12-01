defmodule Toby.Views.System do
  import Toby.Formatting
  import ExTermbox.Renderer.View

  alias Toby.Views.StatusBar

  def render(%{system: system, memory: memory}) do
    status_bar = StatusBar.render(%{selected: :system})

    view(bottom_bar: status_bar) do
      row do
        column(size: 6) do
          panel(title: "system and architecture") do
            table do
              table_row(["system version:", to_string(system.otp_release)])
              table_row(["erts version:", to_string(system.erts_version)])
              table_row(["compiled for:", to_string(system.compiled_for)])
              table_row(["emulator wordsize:", "todo"])
              table_row(["process wordsize:", "todo"])
              table_row(["smp support:", to_string(system.smp_support?)])
              table_row(["thread support:", "todo"])
              table_row(["async thread pool size:", "todo"])
            end
          end
        end

        column(size: 6) do
          panel(title: "memory usage") do
            table do
              table_row(["total", humanize_bytes(memory.total)])
              table_row(["processes", humanize_bytes(memory.processes)])

              table_row([
                "processes (used)",
                humanize_bytes(memory.processes_used)
              ])

              table_row(["system", humanize_bytes(memory.system)])
              table_row(["atoms", humanize_bytes(memory.atom)])
              table_row(["atoms (used)", humanize_bytes(memory.atom_used)])
              table_row(["binary", humanize_bytes(memory.binary)])
              table_row(["code", humanize_bytes(memory.code)])
              table_row(["ets", humanize_bytes(memory.ets)])
            end
          end
        end
      end

      row do
        column(size: 6) do
          panel(title: "cpus & threads") do
            table do
              table_row(["logical cpus:", "todo"])
              table_row(["online logical cpus:", "todo"])
              table_row(["available logical cpus:", "todo"])
              table_row(["schedulers:", "todo"])
              table_row(["online schedulers:", "todo"])
              table_row(["available schedulers:", "todo"])
            end
          end
        end

        column(size: 6) do
          panel(title: "statistics") do
            table do
              table_row(["uptime:", "todo"])
              table_row(["run queue:", "todo"])
              table_row(["io input:", "todo"])
              table_row(["io output:", "todo"])
            end
          end
        end
      end

      row do
        column(size: 12) do
          panel(title: "system statistics / limit") do
            table do
              table_row(["atoms:", "todo"])
              table_row(["processes:", "todo"])
              table_row(["ports:", "todo"])
              table_row(["ets:", "todo"])
              table_row(["distribution buffer busy limit:", "todo"])
            end
          end
        end
      end
    end
  end
end
