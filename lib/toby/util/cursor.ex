defmodule Toby.Util.Cursor do
  @moduledoc """
  Utils for managing cursors
  """

  def next(%{position: position, size: size} = cursor) when position >= size - 1 do
    %{cursor | position: 0}
  end

  def next(cursor) do
    %{cursor | position: cursor.position + 1}
  end

  def previous(%{position: 0} = cursor) do
    %{cursor | position: cursor.size - 1}
  end

  def previous(cursor) do
    %{cursor | position: cursor.position - 1}
  end

  def put_size(%{position: position} = cursor, size) when position > size - 1 do
    %{cursor | position: size - 1, size: size}
  end

  def put_size(cursor, size) do
    %{cursor | size: size}
  end
end
