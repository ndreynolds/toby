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

    totals_by_second =
      for sample <- memory_samples do
        sample[:total] / :math.pow(1024, 2)
      end

    totals_by_second
  end

  def historical_io(samples) do
    io_samples = for %{io: io} <- samples, do: io

    totals_by_second =
      for {{:input, input}, {:output, output}} <- io_samples do
        (input + output) / 1
      end

    totals_by_second
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

    util_by_second
  end

  def historical_allocation(samples) do
    alloc_by_second =
      for %{allocation: allocation} <- samples do
        allocation[:total][:carrier_size] / :math.pow(1024, 2)
      end

    alloc_by_second
  end
end
