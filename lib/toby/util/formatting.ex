defmodule Toby.Util.Formatting do
  @moduledoc """
  Provides formatting helpers for various values.
  """

  @ms_conversions %{
    second: 1000,
    minute: 1000 * 60,
    hour: 1000 * 60 * 60,
    day: 1000 * 60 * 60 * 24
  }

  def format_ms(ms) do
    cond do
      ms >= @ms_conversions.day ->
        format_ms(ms / @ms_conversions.day, {"day", "days"})

      ms >= @ms_conversions.hour ->
        format_ms(ms / @ms_conversions.hour, {"hour", "hours"})

      ms >= @ms_conversions.minute ->
        format_ms(ms / @ms_conversions.minute, {"minute", "minutes"})

      ms >= @ms_conversions.second ->
        format_ms(ms / @ms_conversions.second, {"second", "seconds"})

      true ->
        format_ms(ms, {"ms", "ms"})
    end
  end

  defp format_ms(t, suffixes) when is_float(t) do
    format_ms(:erlang.trunc(t), suffixes)
  end

  defp format_ms(1, {suffix_singular, _}) do
    "1 #{suffix_singular}"
  end

  defp format_ms(t, {_, suffix_plural}) do
    "#{t} #{suffix_plural}"
  end

  @byte_conversions %{
    terabyte: :math.pow(1024, 4),
    gigabyte: :math.pow(1024, 3),
    megabyte: :math.pow(1024, 2),
    kilobyte: 1024
  }

  def format_bytes(bytes) do
    cond do
      bytes >= @byte_conversions.terabyte ->
        format_bytes(bytes / @byte_conversions.terabyte, " TB")

      bytes >= @byte_conversions.gigabyte ->
        format_bytes(bytes / @byte_conversions.gigabyte, " GB")

      bytes >= @byte_conversions.megabyte ->
        format_bytes(bytes / @byte_conversions.megabyte, " MB")

      bytes >= @byte_conversions.kilobyte ->
        format_bytes(bytes / @byte_conversions.kilobyte, " KB")

      true ->
        format_bytes(bytes, "")
    end
  end

  defp format_bytes(bytes, suffix) when is_float(bytes) do
    format_bytes(bytes |> Float.round(2) |> Float.to_string(), suffix)
  end

  defp format_bytes(bytes, suffix) when is_binary(bytes) or is_integer(bytes) do
    to_string(bytes) <> suffix
  end

  def format_func({mod, name, arity}) do
    "#{mod}:#{name}/#{arity}"
  end

  def format_func(_) do
    "(No function)"
  end
end
