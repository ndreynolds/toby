defmodule Toby.Stats.Provider do
  @moduledoc """
  Provides statistics about the running Erlang VM for display in components.

  Since these lookups can be expensive, access this data via `Toby.Stats.Server`
  instead of calling this module directly. The server module provides a
  throttled interface to this data to avoid overwhelming the system.
  """

  def processes do
    for pid <- :erlang.processes() do
      Enum.into(:erlang.process_info(pid), %{
        pid: pid,
        memory: pid |> :erlang.process_info(:memory) |> elem(1)
      })
    end
  end

  def applications do
    app_controller = :erlang.whereis(:application_controller)
    {:links, _apps} = :erlang.process_info(app_controller, :links)

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
