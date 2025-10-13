defmodule Todo.Database do
  @moduledoc """
  A simple key-value store for persisting todo lists to the filesystem.
  It uses a pool of worker processes to handle concurrent read and write operations.
  """

  require Logger

  @db_folder "./persist"
  @pool_size 4

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: @pool_size
      ],
      [@db_folder]
    )
  end

  def store(key, data) do
    :poolboy.transaction(__MODULE__, &Todo.DatabaseWorker.store(&1, key, data))
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, &Todo.DatabaseWorker.get(&1, key))
  end
end
