defmodule Toby.Cursor do
  @moduledoc """
  Utils for managing cursors
  """

  def next(cursor, length) when cursor == length - 1, do: 0
  def next(cursor, _), do: cursor + 1

  def previous(0, length), do: length - 1
  def previous(cursor, length), do: cursor - 1
end
