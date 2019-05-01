defmodule Toby.Util.Cursor do
  @moduledoc """
  Utils for managing cursors
  """

  def next(%{position: position, size: size, continuous: true} = cursor)
      when position >= size - 1 do
    %{cursor | position: 0}
  end

  def next(%{position: position, size: size, continuous: false} = cursor)
      when position >= size - 1 do
    %{cursor | position: size - 1}
  end

  def next(cursor) do
    %{cursor | position: cursor.position + 1}
  end

  def previous(%{position: 0, continuous: true} = cursor) do
    %{cursor | position: cursor.size - 1}
  end

  def previous(%{position: 0, continuous: false} = cursor) do
    %{cursor | position: 0}
  end

  def previous(cursor) do
    %{cursor | position: cursor.position - 1}
  end

  def reset(cursor) do
    %{cursor | position: 0}
  end

  def put_size(%{position: position} = cursor, size) when position > size - 1 do
    %{cursor | position: size - 1, size: size}
  end

  def put_size(cursor, size) do
    %{cursor | size: size}
  end
end
