defmodule Toby.Console do
  @moduledoc """
  A task that runs the main terminal application loop and holds on to
  application state.
  """

  use Task, restart: :transient
  require Logger

  alias Ratatouille.{EventManager, Window}

  alias Toby.Components.Application, as: ApplicationComponent
  alias Toby.Components.Load, as: LoadComponent
  alias Toby.Components.Memory, as: MemoryComponent
  alias Toby.Components.Port, as: PortComponent
  alias Toby.Components.Process, as: ProcessComponent
  alias Toby.Components.System, as: SystemComponent

  @interval_ms 500

  def start_link(_) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    Logger.info("starting console")
    EventManager.subscribe(self())
    loop(SystemComponent, %{})
  end

  def loop(component, init_state) do
    {:ok, state} =
      init_state
      |> Map.put(:window, window_info())
      |> component.tick()

    :ok = Window.update(component.render(state))

    receive do
      {:event, %{ch: ?q}} ->
        Logger.debug("received quit command")
        shutdown()

      {:event, %{ch: ?s}} ->
        loop(SystemComponent, state)

      {:event, %{ch: ?l}} ->
        loop(LoadComponent, state)

      {:event, %{ch: ?m}} ->
        loop(MemoryComponent, state)

      {:event, %{ch: ?a}} ->
        loop(ApplicationComponent, state)

      {:event, %{ch: ?p}} ->
        loop(ProcessComponent, state)

      {:event, %{ch: ?r}} ->
        loop(PortComponent, state)

      {:event, event} ->
        {:ok, new_state} = component.handle_event(event, state)
        loop(component, new_state)
    after
      @interval_ms ->
        loop(component, state)
    end
  end

  def window_info do
    {:ok, height} = Window.fetch(:height)
    %{height: height}
  end

  def shutdown do
    Window.close()
    System.halt()
  end
end
