defmodule Toby.Formatting do
  @bytes %{
    terabyte: :math.pow(1024, 4),
    gigabyte: :math.pow(1024, 3),
    megabyte: :math.pow(1024, 2),
    kilobyte: 1024
  }

  def humanize_bytes(bytes) do
    cond do
      bytes > @bytes.terabyte -> format_bytes(bytes / @bytes.terabyte, "TB")
      bytes > @bytes.gigabyte -> format_bytes(bytes / @bytes.gigabyte, "GB")
      bytes > @bytes.megabyte -> format_bytes(bytes / @bytes.megabyte, "MB")
      bytes > @bytes.kilobyte -> format_bytes(bytes / @bytes.kilobyte, "KB")
      true -> format_bytes(bytes, "")
    end
  end

  def format_bytes(float, suffix) do
    val = float |> Float.round(2) |> Float.to_string()
    "#{val} #{suffix}"
  end
end
