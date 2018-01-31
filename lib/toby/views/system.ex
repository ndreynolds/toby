defmodule Toby.Views.System do
  import Toby.Formatting
  import ExTermbox.Renderer.View

  def render(%{system: system, memory: memory}) do
    new(
      element(:columned_layout, [
        element(:panel, %{title: "System and Architecture"}, [
          element(:table, [
            ["System Version:", to_string(system.otp_release)],
            ["ERTS Version:", to_string(system.erts_version)],
            ["Compiled for:", to_string(system.compiled_for)],
            ["SMP Support:", to_string(system.smp_support?)]
          ])
        ]),
        element(:panel, %{title: "Memory Usage"}, [
          element(:table, [
            ["Total", humanize_bytes(memory.total)],
            ["Processes", humanize_bytes(memory.processes)],
            ["Processes (Used)", humanize_bytes(memory.processes_used)],
            ["System", humanize_bytes(memory.system)],
            ["Atoms", humanize_bytes(memory.atom)],
            ["Atoms (Used)", humanize_bytes(memory.atom_used)],
            ["Binary", humanize_bytes(memory.binary)],
            ["Code", humanize_bytes(memory.code)],
            ["ETS", humanize_bytes(memory.ets)]
          ])
        ])
      ])
    )
  end
end
