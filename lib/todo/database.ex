defmodule Todo.Database do
  require Logger

  @moduledoc """
  A simple key-value store for persisting todo lists to the filesystem.
  It uses a pool of worker processes to handle concurrent read and write operations.
  """

  use Supervisor

  @db_folder "./persist"
  @pool_size 4

  def start_link(_) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Logger.info("Starting database with pool size #{@pool_size}")
    File.mkdir_p!(@db_folder)
    children = Enum.map(1..@pool_size, &{Todo.DatabaseWorker, {@db_folder, &1}})
    Supervisor.init(children, strategy: :one_for_one)
  end

  def get(key) do
    key |> choose_worker() |> Todo.DatabaseWorker.get(key)
  end

  def store(key, data) do
    key |> choose_worker() |> Todo.DatabaseWorker.store(key, data)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
