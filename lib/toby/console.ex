defmodule Toby.Console do
  use Task, restart: :transient
  require Logger

  alias ExTermbox.{Window, Event, EventManager}

  alias Toby.Stats.Server, as: Stats

  alias Toby.Views.Application, as: ApplicationView
  alias Toby.Views.Load, as: LoadView
  alias Toby.Views.Memory, as: MemoryView
  alias Toby.Views.Port, as: PortView
  alias Toby.Views.Process, as: ProcessView
  alias Toby.Views.System, as: SystemView

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
    :ok = ExTermbox.Window.update(view_fn.(state))

    receive do
      {:event, %Event{ch: ?q}} ->
        Logger.debug("received quit command")
        shutdown()

      {:event, %Event{ch: ?s}} ->
        loop(&system_view/1, state)

      {:event, %Event{ch: ?l}} ->
        loop(&load_view/1, state)

      {:event, %Event{ch: ?m}} ->
        loop(&memory_view/1, state)

      {:event, %Event{ch: ?a}} ->
        loop(&application_view/1, state)

      {:event, %Event{ch: ?p}} ->
        loop(&process_view/1, state)

      {:event, %Event{ch: ?r}} ->
        loop(&port_view/1, state)

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
      system: Stats.fetch(:system),
      memory: Stats.fetch(:memory)
    })
  end

  def load_view(_state) do
    LoadView.render(%{})
  end

  def memory_view(_state) do
    MemoryView.render(%{})
  end

  def application_view(_state) do
    ApplicationView.render(%{
      applications: Stats.fetch(:applications)
    })
  end

  def process_view(%{cursor: cursor}) do
    ProcessView.render(%{
      processes: Stats.fetch(:processes),
      selected_index: cursor
    })
  end

  def port_view(_state) do
    PortView.render(%{})
  end
end
