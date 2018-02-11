defmodule Toby.Console do
  use Task, restart: :transient
  require Logger

  alias ExTermbox.{Window, Event, EventManager}

  alias Toby.Statistics
  alias Toby.Views.Application, as: ApplicationView
  alias Toby.Views.System, as: SystemView
  alias Toby.Views.Process, as: ProcessView

  @interval_ms 500

  def start_link(_) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    Logger.info("starting console")
    EventManager.subscribe(self())
    state = %{cursor: 0}
    loop(&system_view/1, state)
  end

  def loop(view_fn, %{cursor: cursor} = state) do
    ExTermbox.Window.update(view_fn.(state))

    receive do
      {:event, %Event{ch: ?q}} ->
        Logger.debug("received quit command")
        shutdown()

      {:event, %Event{ch: ?s}} ->
        loop(&system_view/1, state)

      {:event, %Event{ch: ?p}} ->
        loop(&process_view/1, state)

      {:event, %Event{ch: ?a}} ->
        loop(&application_view/1, state)

      {:event, %Event{ch: ?j}} ->
        loop(view_fn, %{cursor: cursor + 1})

      {:event, %Event{ch: ?k}} ->
        loop(view_fn, %{cursor: cursor - 1})

      {:event, %Event{}} ->
        loop(view_fn, state)
    after
      @interval_ms ->
        loop(view_fn, state)
    end
  end

  def shutdown do
    Window.close()
    System.halt()
  end

  def system_view(_state) do
    SystemView.render(%{
      system: Statistics.system(),
      memory: Statistics.memory()
    })
  end

  def application_view(_state) do
    ApplicationView.render(%{
      applications: Statistics.applications()
    })
  end

  def process_view(%{cursor: cursor}) do
    ProcessView.render(%{
      processes: Statistics.processes(),
      selected_index: cursor
    })
  end
end
