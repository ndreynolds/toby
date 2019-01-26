defmodule Toby.Data.Sampler do
  @moduledoc """
  Collects samples of the current VM state for later use in charts.
  """

  def sample do
    %{
      sampled_at: :erlang.monotonic_time(),
      scheduler_utilization: :scheduler.sample(),
      memory: :erlang.memory(),
      io: :erlang.statistics(:io)
    }
  end
end
