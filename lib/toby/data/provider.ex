defmodule Toby.Data.Provider do
  @moduledoc """
  Provides statistics about the running Erlang VM for display in components.

  Since these lookups can be expensive, access this data via `Toby.Data.Server`
  instead of calling this module directly. The server module provides a
  throttled interface to this data to avoid overwhelming the system.
  """

  alias Toby.Data.{Applications, Node, Samples}

  def provide({node, :node}, _) do
    {:ok,
     %{
       current: node,
       cookie: Node.cookie(node),
       connected_nodes: Node.connected_nodes(),
       visible_nodes: Node.visible_nodes()
     }}
  end

  def provide({node, :processes}, _) do
    {:ok, %{processes: Node.processes_extended(node)}}
  end

  def provide({node, :ports}, _) do
    {:ok, %{ports: Node.ports_extended(node)}}
  end

  def provide({node, :applications}, _) do
    with {:ok, apps} <- Applications.applications(node) do
      {:ok,
       %{
         applications: Enum.sort_by(apps, &to_string/1)
       }}
    end
  end

  def provide({node, :system}, _) do
    {:ok,
     %{
       cpu: system_cpu(node),
       limits: system_limits(node),
       memory: system_memory(node),
       statistics: system_statistics(node),
       system: system_data(node)
     }}
  end

  def provide({node, :load}, samples) do
    {:ok,
     %{
       utilization: Samples.historical_scheduler_utilization(samples),
       scheduler_count: system_cpu(node).schedulers,
       memory: Samples.historical_memory(samples),
       io: Samples.historical_io(samples)
     }}
  end

  def provide({node, :memory}, samples) do
    {:ok,
     %{
       allocators: Node.allocators(node),
       allocation_history: Samples.historical_allocation(samples)
     }}
  end

  def provide({node, :application, app}, _) do
    Applications.application(node, app)
  end

  def provide(_other_key, _) do
    {:error, :invalid_key}
  end

  def system_data(node) do
    %{
      otp_release: Node.system_info(node, :otp_release),
      erts_version: Node.system_info(node, :version),
      compiled_for: Node.system_info(node, :system_architecture),
      emulator_wordsize: Node.system_info(node, {:wordsize, :internal}),
      process_wordsize: Node.system_info(node, {:wordsize, :external}),
      smp_support?: Node.system_info(node, :smp_support),
      thread_support?: Node.system_info(node, :threads),
      async_thread_pool_size: Node.system_info(node, :thread_pool_size)
    }
  end

  def system_cpu(node) do
    %{
      logical_cpus: Node.system_info(node, :logical_processors),
      online_logical_cpus: Node.system_info(node, :logical_processors),
      available_logical_cpus: Node.system_info(node, :logical_processors),
      schedulers: Node.system_info(node, :schedulers),
      online_schedulers: Node.system_info(node, :schedulers_online),
      available_schedulers: Node.system_info(node, :schedulers_online)
    }
  end

  def system_limits(node) do
    %{
      atoms:
        limit(Node.system_info(node, :atom_count), Node.system_info(node, :atom_limit)),
      procs:
        limit(
          Node.system_info(node, :process_count),
          Node.system_info(node, :process_limit)
        ),
      ports:
        limit(Node.system_info(node, :port_count), Node.system_info(node, :port_limit)),
      ets: limit(Node.system_info(node, :ets_count), Node.system_info(node, :ets_limit)),
      dist_buffer_busy: Node.system_info(node, :dist_buf_busy_limit)
    }
  end

  def system_statistics(node) do
    {{:input, io_input}, {:output, io_output}} = Node.statistics(node, :io)

    %{
      uptime_ms: uptime_ms(node),
      run_queue: Node.statistics(node, :total_run_queue_lengths),
      io_input_bytes: io_input,
      io_output_bytes: io_output
    }
  end

  def system_memory(node) do
    Enum.into(Node.memory(node), %{})
  end

  defp limit(count, limit) do
    %{count: count, limit: limit, percent_used: percent(count, limit)}
  end

  defp percent(_, 0), do: 0
  defp percent(x, y), do: :erlang.trunc(Float.round(x / y, 2) * 100)

  defp uptime_ms(node) do
    {total_ms, _since_last_call_ms} = Node.statistics(node, :wall_clock)
    total_ms
  end
end
