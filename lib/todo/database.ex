defmodule Todo.Database do
  require Logger

  @moduledoc """
  A simple key-value store for persisting todo lists to the filesystem.
  It uses a pool of worker processes to handle concurrent read and write operations.
  """

  use GenServer

  alias Todo.DatabaseWorker

  @db_folder "./persist"

  def start(pool_size \\ 3) do
    GenServer.start(__MODULE__, %{pool_size: pool_size}, name: __MODULE__)
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end

  #### Callbacks

  @impl true
  def init(%{pool_size: pool_size}) do
    Logger.info("Starting database with pool size #{pool_size}")
    {:ok, %{pool_size: pool_size, workers: initialize_workers(pool_size)}}
  end

  @impl true
  def handle_cast({:store, key, data}, state) do
    key |> choose_worker(state) |> GenServer.cast({:store, key, data})
    {:noreply, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    data = key |> choose_worker(state) |> GenServer.call({:get, key})
    {:reply, data, state}
  end

  defp choose_worker(key, %{pool_size: pool_size, workers: workers}) do
    workers |> Map.get(:erlang.phash2(key, pool_size))
  end

  defp initialize_workers(pool_size) do
    0..(pool_size - 1)
    |> Enum.reduce(%{}, fn key, acc ->
      {:ok, pid} = DatabaseWorker.start(@db_folder)
      Map.put(acc, key, pid)
    end)
  end
end
