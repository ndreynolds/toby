defmodule Toby.Data.Node do
  @moduledoc """
  Retrieves system information for a particular connected node
  """

  # General

  def system_info(node, key) do
    call(node, :erlang, :system_info, [key])
  end

  def memory(node) do
    call(node, :erlang, :memory)
  end

  def statistics(node, key) do
    call(node, :erlang, :statistics, [key])
  end

  def where_is(node, name) do
    call(node, :erlang, :whereis, [name])
  end

  def cookie(node) do
    call(node, :erlang, :get_cookie)
  end

  def monotonic_time(node) do
    call(node, :erlang, :monotonic_time)
  end

  def sample_schedulers(node) do
    call(node, :scheduler, :sample)
  end

  # Processes

  def processes(node) do
    call(node, :erlang, :processes)
  end

  def processes_extended(node) do
    for pid <- processes(node), do: process_info_extended(node, pid)
  end

  def process_info(node, pid) do
    call(node, :erlang, :process_info, [pid])
  end

  def process_info(node, pid, key) do
    call(node, :erlang, :process_info, [pid, key])
  end

  def process_info_extended(node, pid) do
    with {:memory, memory} <- process_info(node, pid, :memory),
         {:monitors, monitors} <- process_info(node, pid, :monitors),
         {:monitored_by, monitored_by} <- process_info(node, pid, :monitored_by),
         info <- process_info(node, pid) do
      info
      |> Enum.into(%{})
      |> Map.merge(%{
        pid: pid,
        memory: memory,
        monitors: monitors,
        monitored_by: monitored_by
      })
    else
      _ ->
        %{pid: pid, links: [], monitors: [], monitored_by: []}
    end
  end

  # Ports

  def ports(node) do
    call(node, :erlang, :ports)
  end

  def ports_extended(node) do
    for port <- ports(node), do: port_info_extended(node, port)
  end

  def port_info(node, port) do
    call(node, :erlang, :port_info, [port])
  end

  def port_info(node, port, key) do
    call(node, :erlang, :port_info, [port, key])
  end

  def port_info_extended(node, port) do
    with {:memory, memory} <- port_info(node, port, :memory),
         {:queue_size, queue_size} <- port_info(node, port, :queue_size),
         {:parallelism, parallelism} <- port_info(node, port, :parallelism),
         {:locking, locking} <- port_info(node, port, :locking),
         {:monitors, monitors} <- port_info(node, port, :monitors),
         {:monitored_by, monitored_by} = port_info(node, port, :monitored_by),
         info <- port_info(node, port) do
      info
      |> Enum.into(%{})
      |> Map.merge(%{
        id: port,
        slot: info[:id],
        memory: memory,
        queue_size: queue_size,
        parallelism: parallelism,
        locking: locking,
        monitors: monitors,
        monitored_by: monitored_by
      })
    else
      :undefined ->
        %{id: port, links: [], monitors: [], monitored_by: []}
    end
  end

  # Applications

  def application(node, name) do
    call(node, :application, :get_all_key, [name])
  end

  def application_by_pid(node, pid) do
    call(node, :application, :get_application, [pid])
  end

  # Allocators

  def allocators(node) do
    allocs =
      for alloc <- erts_allocator_names(node), into: %{} do
        {alloc, allocator(node, alloc)}
      end

    total =
      for {_, alloc} <- allocs, reduce: %{block_size: 0, carrier_size: 0} do
        acc ->
          %{
            block_size: acc.block_size + alloc.block_size,
            carrier_size: acc.carrier_size + alloc.carrier_size
          }
      end

    Map.merge(allocs, %{total: total})
  end

  def allocator(node, alloc) do
    data = call(node, :erlang, :alloc_sizes, [alloc])

    for {:instance, _, values} <- data, reduce: %{block_size: 0, carrier_size: 0} do
      acc ->
        with [
               {:blocks_size, mbcs_block_size, _, _},
               {:carriers_size, mbcs_carrier_size, _, _}
             ] <- values[:mbcs],
             [
               {:blocks_size, sbcs_block_size, _, _},
               {:carriers_size, sbcs_carrier_size, _, _}
             ] <- values[:sbcs] do
          %{
            block_size: acc.block_size + mbcs_block_size + sbcs_block_size,
            carrier_size: acc.carrier_size + mbcs_carrier_size + sbcs_carrier_size
          }
        else
          _ -> acc
        end
    end
  end

  defp erts_allocator_names(node) do
    call(node, :erlang, :system_info, [:alloc_util_allocators])
  end

  # Nodes

  def visible_nodes do
    case :net_adm.names() do
      {:ok, visible} -> visible
      {:error, _} -> []
    end
  end

  def connected_nodes, do: [Node.self() | Node.list()]

  def self, do: Node.self()

  # Utility

  defp call(node, module, func, args \\ []) do
    :rpc.call(node, module, func, args)
  end
end
