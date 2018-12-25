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

  def fetch(pid \\ __MODULE__, key) do
    GenServer.call(pid, {:fetch, key})
  end

  def fetch!(pid \\ __MODULE__, key) do
    {:ok, value} = fetch(pid, key)
    value
  end

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:fetch, name}, _from, cache) do
    case fetch_cached(cache, name) do
      {:ok, value, updated_cache} ->
        {:reply, {:ok, value}, updated_cache}

      {:error, error} ->
        {:reply, {:error, error}, cache}
    end
  end

  defp fetch_cached(cache, key) do
    case cache[key] do
      {value, expires_at} ->
        if expires_at > now() do
          {:ok, value, cache}
        else
          fetch_new(cache, key)
        end

      _ ->
        fetch_new(cache, key)
    end
  end

  defp fetch_new(cache, key) do
    with {:ok, new_value} <- Provider.provide(key) do
      {:ok, new_value, put_cache_entry(cache, key, new_value)}
    end
  end

  defp put_cache_entry(cache, key, value) do
    Map.put(cache, key, {value, now() + @cache_ms})
  end

  defp now, do: :erlang.monotonic_time(:millisecond)
end
