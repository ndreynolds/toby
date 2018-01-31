defmodule Toby.Views.Process do
  import ExTermbox.Renderer.View

  def render(processes) do
    new(
      element(:columned_layout, [
        element(:panel, %{title: "Processes"}, [
          element(
            :table,
            [
              [
                "PID",
                "Name or Initial Func",
                "Reds",
                "Memory",
                "MsgQ",
                "Current Function"
              ]
            ] ++
              Enum.map(processes, fn process ->
                [
                  inspect(process.pid),
                  "TODO",
                  to_string(process.reductions),
                  "TODO",
                  to_string(process.message_queue_len),
                  "TODO"
                ]
              end)
          )
        ])
      ])
    )
  end
end
