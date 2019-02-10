defmodule Toby.Util.Selection do
  @moduledoc """
  Utils for managing a user selection with a collection
  """

  def slice(items, n, idx) when idx < n do
    Enum.take(items, n)
  end

  def slice(items, n, idx) do
    items
    |> Enum.drop(idx - n + 1)
    |> Enum.take(n)
  end
end
