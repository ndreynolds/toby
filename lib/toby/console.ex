defmodule Toby.Console do
  use Task

  alias ExTermbox.{Window, Event, EventManager}

  alias Toby.Statistics
  alias Toby.Views.System, as: SystemView
  alias Toby.Views.Process, as: ProcessView

  @interval_ms 500

  def start_link(_) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    EventManager.subscribe(self())
    loop(&system_view/0)
  end

  def loop(view_fn) do
    ExTermbox.Window.update(view_fn.())

    receive do
      {:event, %Event{ch: ?q}} ->
        shutdown()

      {:event, %Event{ch: ?p}} ->
        loop(&process_view/0)

      {:event, %Event{ch: ?s}} ->
        loop(&system_view/0)

      {:event, %Event{}} ->
        loop(view_fn)
    after
      @interval_ms ->
        loop(view_fn)
    end
  end

  def shutdown do
    Window.close()
    System.halt()
  end

  def system_view do
    SystemView.render(%{
      system: Statistics.system(),
      memory: Statistics.memory()
    })
  end

  def process_view do
    ProcessView.render(Statistics.processes())
  end
end
