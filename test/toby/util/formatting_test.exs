defmodule Toby.Util.FormattingTest do
  use ExUnit.Case, async: true

  import Toby.Util.Formatting

  describe "format_ms/1" do
    test "formats milliseconds as a human-readable string" do
      assert format_ms(542) == "542 ms"

      assert format_ms(1000) == "1 second"
      assert format_ms(1999) == "1 second"
      assert format_ms(2000) == "2 seconds"

      assert format_ms(60_000) == "1 minute"
      assert format_ms(119_999) == "1 minute"
      assert format_ms(120_000) == "2 minutes"

      assert format_ms(3_600_000) == "1 hour"
      assert format_ms(86_399_999) == "23 hours"

      assert format_ms(86_400_000) == "1 day"
      assert format_ms(86_400_000 * 100) == "100 days"
    end
  end

  @kb 1024
  @mb :math.pow(1024, 2)
  @gb :math.pow(1024, 3)
  @tb :math.pow(1024, 4)

  describe "format_bytes/1" do
    test "formats bytes as a human-readable string" do
      assert format_bytes(42) == "42"
      assert format_bytes(1023) == "1023"

      assert format_bytes(@kb) == "1.0 KB"
      assert format_bytes(@kb + 100) == "1.1 KB"
      assert format_bytes(@mb - @kb) == "1023.0 KB"

      assert format_bytes(@mb) == "1.0 MB"
      assert format_bytes(@mb + 10 * @kb) == "1.01 MB"
      assert format_bytes(@gb - @mb) == "1023.0 MB"

      assert format_bytes(@gb) == "1.0 GB"
      assert format_bytes(@gb + 10 * @mb) == "1.01 GB"
      assert format_bytes(@tb - @gb) == "1023.0 GB"

      assert format_bytes(@tb) == "1.0 TB"
      assert format_bytes(@tb + 10 * @gb) == "1.01 TB"
    end
  end

  describe "format_func/1" do
    test "formats an MFA as a human-readable string" do
      assert format_func({Toby.Formatting, :format_func, 1}) ==
               "Elixir.Toby.Formatting:format_func/1"

      assert format_func({:erlang, :process_info, 1}) == "erlang:process_info/1"
    end
  end
end
