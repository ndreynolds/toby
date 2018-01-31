defmodule Toby.Statistics do
  def processes do
    :erlang.processes()
    |> Enum.map(fn pid ->
      Enum.into(:erlang.process_info(pid), %{pid: pid})
    end)
  end

  def system do
    %{
      otp_release: :erlang.system_info(:otp_release),
      erts_version: :erlang.system_info(:version),
      compiled_for: "TODO",
      smp_support?: :erlang.system_info(:smp_support)
    }
  end

  def memory do
    Enum.into(:erlang.memory(), %{})
  end
end
