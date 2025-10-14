defmodule Todo.Database do
  @moduledoc """
  A simple key-value store for persisting todo lists to the filesystem.
  It uses a pool of worker processes to handle concurrent read and write operations.
  """

  require Logger

  @db_folder Application.compile_env!(:todo, :database_folder)
  @pool_size Application.compile_env!(:todo, :database_pool_size)

  def child_spec(_) do
    create_db()

    start =
      {:poolboy, :start_link,
       [
         [name: {:local, __MODULE__}, worker_module: Todo.DatabaseWorker, size: @pool_size],
         [@db_folder]
       ]}

    %{
      id: __MODULE__,
      start: start,
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  def store(key, data) do
    :erpc.multicall(
      Node.list([:this, :visible]),
      __MODULE__,
      :store_local,
      [key, data],
      :timer.seconds(5)
    )
  end

  def store_local(key, data) do
    :poolboy.transaction(__MODULE__, &Todo.DatabaseWorker.store(&1, key, data))
  end

  def get(key) do
    :poolboy.transaction(__MODULE__, &Todo.DatabaseWorker.get(&1, key))
  end

  defp create_db do
    File.mkdir_p!("#{@db_folder}/#{node_name()}")
  end

  defp node_name do
    node() |> to_string() |> String.split("@") |> hd()
  end
end
