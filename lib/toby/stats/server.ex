defmodule Toby.Stats.Server do
  @moduledoc """
  A caching layer on top of Toby.Stats.Provider so that system information can
  be retrieved on an interval independent of the window refresh rate.
  """

  use GenServer

  alias Toby.Stats.Provider

  @cache_ms 2000

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def fetch(pid \\ __MODULE__, name) do
    GenServer.call(pid, {:fetch, name})
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:fetch, name}, _from, cache) do
    {:ok, value, updated_cache} = fetch_cached(cache, name)

    {:reply, value, updated_cache}
  end

  defp fetch_cached(cache, name) do
    updated_cache =
      case cache[name] do
        {_value, expires_at} ->
          if expires_at > now(), do: cache, else: update_cache(cache, name)

        _ ->
          update_cache(cache, name)
      end

    {value, _expires_at} = updated_cache[name]

    {:ok, value, updated_cache}
  end

  defp update_cache(cache, name) do
    new_entry = {compute(name), now() + @cache_ms}

    Map.put(cache, name, new_entry)
  end

  defp compute(name) do
    case name do
      :applications -> Provider.applications()
      :cpu -> Provider.cpu()
      :limits -> Provider.limits()
      :memory -> Provider.memory()
      :processes -> Provider.processes()
      :statistics -> Provider.statistics()
      :system -> Provider.system()
    end
  end

  defp now, do: :erlang.monotonic_time(:millisecond)
end
