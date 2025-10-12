defmodule SimpleRegistry do
  @moduledoc """
  A simple process registry using ETS for storing process names and their associated PIDs.
  It automatically cleans up entries when registered processes exit.
  """

  use GenServer
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def register(name) do
    Process.link(Process.whereis(__MODULE__))

    if :ets.insert_new(__MODULE__, {name, self()}) do
      :ok
    else
      :error
    end
  end

  def whereis(name) do
    case :ets.lookup(__MODULE__, name) do
      [{^name, pid}] -> pid
      _ -> nil
    end
  end

  @impl true
  def init(_) do
    Process.flag(:trap_exit, true)
    table = :ets.new(__MODULE__, [:named_table, :public, write_concurrency: true])
    {:ok, table}
  end

  @impl true
  def handle_info({:EXIT, from_pid, _reason}, table) do
    Logger.info("Process #{inspect(from_pid)} exit")
    :ets.match_delete(table, {:_, from_pid})
    {:noreply, table}
  end
end
