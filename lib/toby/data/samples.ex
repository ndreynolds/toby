defmodule Toby.Data.Samples do
  @moduledoc """
  Collects samples of the current VM state for later use in charts.
  """

  alias Toby.Data.Node

  def collect(node) do
    %{
      sampled_at: Node.monotonic_time(node),
      scheduler_utilization: Node.sample_schedulers(node),
      memory: Node.memory(node),
      io: Node.statistics(node, :io),
      allocation: Node.allocators(node)
    }
  end

  def historical_memory(samples) do
    memory_samples = for %{memory: memory} <- samples, do: memory

    for sample <- memory_samples do
      sample[:total] / :math.pow(1024, 2)
    end
  end

  def historical_io(samples) do
    io_samples = for %{io: io} <- samples, do: io

    for {{:input, input}, {:output, output}} <- io_samples do
      (input + output) / 1
    end
  end

  def historical_scheduler_utilization(samples) do
    util_samples = for %{scheduler_utilization: util} <- samples, do: util

    for {sample, next_sample} <- Enum.zip(util_samples, Enum.drop(util_samples, 1)) do
      [{:total, total, _} | rest] = :scheduler.utilization(sample, next_sample)

      for {:normal, id, util, _} <- rest, into: %{total: total * 100} do
        {id, util * 100}
      end
    end
  end

  def historical_allocation(samples) do
    for %{allocation: allocation} <- samples do
      for {type, data} <- allocation, into: %{} do
        {type, data[:carrier_size] / :math.pow(1024, 2)}
      end
    end
  end
end
