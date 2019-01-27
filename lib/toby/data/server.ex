defmodule Toby.Data.Server do
  @moduledoc """
  A caching layer on top of `Toby.Data.Provider` so that system information can
  be retrieved on an interval independent of the window refresh rate.
  """

  use GenServer

  alias Toby.Data.{Provider, Sampler}

  @cache_ms 2000

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def fetch(pid \\ __MODULE__, key) do
    GenServer.call(pid, {:fetch, key})
  end

  def fetch!(pid \\ __MODULE__, key) do
    {:ok, value} = fetch(pid, key)
    value
  end

  @impl true
  def init(:ok) do
    Process.send_after(self(), :sample, 100)
    {:ok, %{cache: %{}, samples: []}}
  end

  @impl true
  def handle_call({:fetch, name}, _from, state) do
    case fetch_cached(state, name) do
      {:ok, value, state} ->
        {:reply, {:ok, value}, state}

      {:error, error} ->
        {:reply, {:error, error}, state}
    end
  end

  @impl true
  def handle_info(:sample, state) do
    Process.send_after(self(), :sample, 1000)

    new_samples = [Sampler.sample() | Enum.take(state.samples, 59)]

    {:noreply, %{state | samples: new_samples}}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end

  defp fetch_cached(state, key) do
    case state.cache[key] do
      {value, expires_at} ->
        if expires_at > now() do
          {:ok, value, state}
        else
          fetch_new(state, key)
        end

      _ ->
        fetch_new(state, key)
    end
  end

  defp fetch_new(state, key) do
    with {:ok, new_value} <- Provider.provide(key, state.samples) do
      {:ok, new_value, %{state | cache: put_cache_entry(state.cache, key, new_value)}}
    end
  end

  defp put_cache_entry(cache, key, value) do
    Map.put(cache, key, {value, now() + @cache_ms})
  end

  defp now, do: :erlang.monotonic_time(:millisecond)
end
