defmodule Toby.Formatting do
  @moduledoc """
  Provides formatting helpers for various values.
  """

  @ms_conversions %{
    second: 1000,
    minute: 1000 * 60,
    hour: 1000 * 60 * 60,
    day: 1000 * 60 * 60 * 24
  }

  def humanize_relative_time(ms) do
    cond do
      ms > @ms_conversions.day ->
        format_relative_time(ms / @ms_conversions.day, {"day", "days"})

      ms > @ms_conversions.hour ->
        format_relative_time(ms / @ms_conversions.hour, {"hour", "hours"})

      ms > @ms_conversions.minute ->
        format_relative_time(ms / @ms_conversions.minute, {"minute", "minutes"})

      ms > @ms_conversions.second ->
        format_relative_time(ms / @ms_conversions.second, {"second", "seconds"})

      true ->
        format_relative_time(ms, {"ms", "ms"})
    end
  end

  def format_relative_time(t, suffixes) when is_float(t) do
    format_relative_time(:erlang.trunc(t), suffixes)
  end

  def format_relative_time(1, {suffix_singular, _}) do
    "1 #{suffix_singular}"
  end

  def format_relative_time(t, {_, suffix_plural}) do
    "#{t} #{suffix_plural}"
  end

  @byte_conversions %{
    terabyte: :math.pow(1024, 4),
    gigabyte: :math.pow(1024, 3),
    megabyte: :math.pow(1024, 2),
    kilobyte: 1024
  }

  def humanize_bytes(bytes) do
    cond do
      bytes > @byte_conversions.terabyte ->
        format_bytes(bytes / @byte_conversions.terabyte, "TB")

      bytes > @byte_conversions.gigabyte ->
        format_bytes(bytes / @byte_conversions.gigabyte, "GB")

      bytes > @byte_conversions.megabyte ->
        format_bytes(bytes / @byte_conversions.megabyte, "MB")

      bytes > @byte_conversions.kilobyte ->
        format_bytes(bytes / @byte_conversions.kilobyte, "KB")

      true ->
        format_bytes(bytes, "")
    end
  end

  def format_bytes(float, suffix) do
    val = float |> Float.round(2) |> Float.to_string()
    "#{val} #{suffix}"
  end

  def format_func({mod, name, arity}) do
    "#{mod}:#{name}/#{arity}"
  end
end
