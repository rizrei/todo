defmodule Todo.Database do
  require Logger

  @moduledoc """
  A simple key-value store for persisting todo lists to the filesystem.
  It uses a pool of worker processes to handle concurrent read and write operations.
  """

  alias Todo.DatabaseWorker

  @db_folder "./persist"
  @pool_size 4

  def start_link do
    Logger.info("Starting database with pool size #{@pool_size}")
    File.mkdir_p!(@db_folder)
    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def get(key) do
    key |> choose_worker() |> DatabaseWorker.get(key)
  end

  def store(key, data) do
    key |> choose_worker() |> DatabaseWorker.store(key, data)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  defp worker_spec(worker_id) do
    default_worker_spec = {Todo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end
end
