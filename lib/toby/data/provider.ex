defmodule Toby.Data.Provider do
  @moduledoc """
  Provides statistics about the running Erlang VM for display in components.

  Since these lookups can be expensive, access this data via `Toby.Data.Server`
  instead of calling this module directly. The server module provides a
  throttled interface to this data to avoid overwhelming the system.
  """

  alias Toby.Data.{Applications, Nodes}

  def provide(:node, _) do
    {:ok,
     %{
       current: Node.self(),
       cookie: Node.get_cookie(),
       connected_nodes: Nodes.connected(),
       visible_nodes: Nodes.visible()
     }}
  end

  def provide(:processes, _) do
    {:ok,
     %{
       processes: for(pid <- Process.list(), do: extended_process_info(pid))
     }}
  end

  def provide(:ports, _) do
    {:ok,
     %{
       ports: for(port <- Port.list(), do: extended_port_info(port))
     }}
  end

  def provide(:applications, _) do
    with {:ok, apps} <- Applications.applications() do
      {:ok,
       %{
         applications: Enum.sort_by(apps, &to_string/1)
       }}
    end
  end

  def provide(:system, _) do
    {:ok,
     %{
       cpu: system_cpu(),
       limits: system_limits(),
       memory: system_memory(),
       statistics: system_statistics(),
       system: system_data()
     }}
  end

  def provide(:load, samples) do
    {:ok,
     %{
       utilization: historical_scheduler_utilization(samples),
       scheduler_count: system_cpu().schedulers,
       memory: historical_memory(samples),
       io: historical_io(samples)
     }}
  end

  def provide(:memory, _) do
    {:ok, %{}}
  end

  def provide({:application, app}, _) do
    Applications.application(app)
  end

  def provide(_other_key, _) do
    {:error, :invalid_key}
  end

  def historical_memory(samples) do
    memory_samples = for %{memory: memory} <- samples, do: memory

    totals_by_second =
      for sample <- memory_samples do
        sample[:total] / :math.pow(1024, 2)
      end

    Enum.reverse(totals_by_second)
  end

  def historical_io(samples) do
    io_samples = for %{io: io} <- samples, do: io

    totals_by_second =
      for {{:input, input}, {:output, output}} <- io_samples do
        (input + output) / 1
      end

    Enum.reverse(totals_by_second)
  end

  def historical_scheduler_utilization(samples) do
    util_samples = for %{scheduler_utilization: util} <- samples, do: util

    util_by_second =
      for {sample, next_sample} <- Enum.zip(util_samples, Enum.drop(util_samples, 1)) do
        [{:total, total, _} | rest] = :scheduler.utilization(sample, next_sample)

        for {:normal, id, util, _} <- rest, into: %{total: total * 100} do
          {id, util * 100}
        end
      end

    Enum.reverse(util_by_second)
  end

  def system_data do
    %{
      otp_release: system_info(:otp_release),
      erts_version: system_info(:version),
      compiled_for: system_info(:system_architecture),
      emulator_wordsize: system_info({:wordsize, :internal}),
      process_wordsize: system_info({:wordsize, :external}),
      smp_support?: system_info(:smp_support),
      thread_support?: system_info(:threads),
      async_thread_pool_size: system_info(:thread_pool_size)
    }
  end

  def system_cpu do
    %{
      logical_cpus: system_info(:logical_processors),
      online_logical_cpus: system_info(:logical_processors),
      available_logical_cpus: system_info(:logical_processors),
      schedulers: system_info(:schedulers),
      online_schedulers: system_info(:schedulers_online),
      available_schedulers: system_info(:schedulers_online)
    }
  end

  def system_limits do
    %{
      atoms: limit(system_info(:atom_count), system_info(:atom_limit)),
      procs: limit(system_info(:process_count), system_info(:process_limit)),
      ports: limit(system_info(:port_count), system_info(:port_limit)),
      ets: limit(system_info(:ets_count), system_info(:ets_limit)),
      dist_buffer_busy: system_info(:dist_buf_busy_limit)
    }
  end

  def system_statistics do
    {{:input, io_input}, {:output, io_output}} = :erlang.statistics(:io)

    %{
      uptime_ms: uptime_ms(),
      run_queue: :erlang.statistics(:total_run_queue_lengths),
      io_input_bytes: io_input,
      io_output_bytes: io_output
    }
  end

  def system_memory do
    Enum.into(:erlang.memory(), %{})
  end

  def extended_process_info(pid) do
    {:memory, memory} = Process.info(pid, :memory)
    {:monitors, monitors} = Process.info(pid, :monitors)
    {:monitored_by, monitored_by} = Process.info(pid, :monitored_by)

    pid
    |> Process.info()
    |> Enum.into(%{
      pid: pid,
      memory: memory,
      monitors: monitors,
      monitored_by: monitored_by
    })
  end

  def extended_port_info(port) do
    case Port.info(port) do
      :undefined ->
        %{}

      info ->
        {:monitors, monitors} = Port.info(port, :monitors)
        {:monitored_by, monitored_by} = Port.info(port, :monitored_by)

        info
        |> Enum.into(%{})
        |> Map.merge(%{
          id: port,
          slot: info[:id],
          monitors: monitors,
          monitored_by: monitored_by
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

  defp system_info(key), do: :erlang.system_info(key)
end
