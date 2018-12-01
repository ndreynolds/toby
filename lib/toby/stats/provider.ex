defmodule Toby.Stats.Provider do
  def processes do
    for pid <- :erlang.processes() do
      Enum.into(:erlang.process_info(pid), %{
        pid: pid,
        memory: :erlang.process_info(pid, :memory) |> elem(1)
      })
    end
  end

  def applications do
    ac_pid = :erlang.whereis(:application_controller)
    {:links, _apps} = :erlang.process_info(ac_pid, :links)

    Enum.map(
      :application.loaded_applications(),
      &elem(&1, 0)
    )
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
