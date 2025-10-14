defmodule Todo.Metrics do
  @moduledoc """
  A simple metrics collector that periodically logs system metrics such as memory usage and process count.
  """

  use Task
  require Logger

  @spec start_link(integer()) :: {:ok, pid()} | {:error, term()}
  def start_link(seconds \\ 10) do
    Task.start_link(__MODULE__, :loop, [seconds])
  end

  @spec loop(integer()) :: no_return()
  def loop(seconds) do
    Process.sleep(:timer.seconds(seconds))
    Logger.info(collect_metrics())
    loop(seconds)
  end

  defp collect_metrics do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
