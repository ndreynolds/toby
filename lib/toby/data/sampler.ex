defmodule Toby.Data.Sampler do
  @moduledoc """
  Collects samples of the current VM state for later use in charts.
  """

  alias Toby.Data.Node

  def sample(node) do
    %{
      sampled_at: Node.monotonic_time(node),
      scheduler_utilization: Node.sample_schedulers(node),
      memory: Node.memory(node),
      io: Node.statistics(node, :io)
    }
  end
end
