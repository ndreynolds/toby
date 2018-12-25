defmodule Toby.Stats.Provider do
  @moduledoc """
  Provides statistics about the running Erlang VM for display in components.

  Since these lookups can be expensive, access this data via `Toby.Stats.Server`
  instead of calling this module directly. The server module provides a
  throttled interface to this data to avoid overwhelming the system.
  """

  alias Toby.Stats.Applications

  def provide(:processes) do
    {:ok, for(pid <- :erlang.processes(), do: extended_process_info(pid))}
  end

  def provide(:ports) do
    {:ok, for(port <- :erlang.ports(), do: extended_port_info(port))}
  end

  def provide(:applications), do: Applications.applications()

  def provide({:application, app}), do: Applications.application(app)

  def provide(:system) do
    {:ok,
     %{
       otp_release: system_info(:otp_release),
       erts_version: system_info(:version),
       compiled_for: system_info(:system_architecture),
       emulator_wordsize: system_info({:wordsize, :internal}),
       process_wordsize: system_info({:wordsize, :external}),
       smp_support?: system_info(:smp_support),
       thread_support?: system_info(:threads),
       async_thread_pool_size: system_info(:thread_pool_size)
     }}
  end

  def provide(:cpu) do
    {:ok,
     %{
       logical_cpus: :erlang.system_info(:logical_processors),
       online_logical_cpus: :erlang.system_info(:logical_processors),
       available_logical_cpus: :erlang.system_info(:logical_processors),
       schedulers: :erlang.system_info(:schedulers),
       online_schedulers: :erlang.system_info(:schedulers_online),
       available_schedulers: :erlang.system_info(:schedulers_online)
     }}
  end

  def provide(:limits) do
    {:ok,
     %{
       atoms: limit(system_info(:atom_count), system_info(:atom_limit)),
       procs: limit(system_info(:process_count), system_info(:process_limit)),
       ports: limit(system_info(:port_count), system_info(:port_limit)),
       ets: limit(system_info(:ets_count), system_info(:ets_limit)),
       dist_buffer_busy: system_info(:dist_buf_busy_limit)
     }}
  end

  def provide(:statistics) do
    {{:input, io_input}, {:output, io_output}} = :erlang.statistics(:io)

    {:ok,
     %{
       uptime_ms: uptime_ms(),
       run_queue: :erlang.statistics(:total_run_queue_lengths),
       io_input_bytes: io_input,
       io_output_bytes: io_output
     }}
  end

  def provide(:memory) do
    {:ok, Enum.into(:erlang.memory(), %{})}
  end

  def provide(_other_key) do
    {:error, :invalid_key}
  end

  def extended_process_info(pid) do
    {:memory, memory} = :erlang.process_info(pid, :memory)

    pid
    |> process_info()
    |> Enum.into(%{
      pid: pid,
      memory: memory
    })
  end

  def extended_port_info(port) do
    case :erlang.port_info(port) do
      :undefined ->
        %{}

      info ->
        info
        |> Enum.into(%{})
        |> Map.merge(%{
          id: port,
          slot: info[:id]
        })
    end
  end

  defp limit(count, limit) do
    %{count: count, limit: limit, percent_used: percent(count, limit)}
  end

  defp percent(_, 0), do: 0
  defp percent(x, y), do: :erlang.trunc(Float.round(x / y, 2) * 100)

  defp uptime_ms do
    {total_ms, _since_last_call_ms} = :erlang.statistics(:wall_clock)
    total_ms
  end

  defp process_info(pid), do: :erlang.process_info(pid)
  defp system_info(key), do: :erlang.system_info(key)
end
