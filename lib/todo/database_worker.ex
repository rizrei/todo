defmodule Todo.DatabaseWorker do
  @moduledoc """
  A worker process responsible for storing and retrieving todo list data from the filesystem.
  """

  use GenServer
  require Logger

  def start_link({db_folder, worker_id}) do
    GenServer.start_link(__MODULE__, {db_folder, worker_id}, name: via_tuple(worker_id))
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  #### Callbacks

  @impl true
  def init({db_folder, worker_id}) do
    File.mkdir_p!(db_folder)
    Logger.info("Starting database worker #{worker_id}")
    {:ok, %{db_folder: db_folder, id: worker_id}}
  end

  @impl true
  def handle_call({:get, key}, from, %{db_folder: db_folder} = state) do
    spawn(fn ->
      data =
        case build_file_path(db_folder, key) |> File.read() do
          {:ok, contents} -> :erlang.binary_to_term(contents)
          {:error, :enoent} -> nil
        end

      GenServer.reply(from, data)
    end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:store, key, data}, %{db_folder: db_folder} = state) do
    spawn(fn -> build_file_path(db_folder, key) |> File.write!(:erlang.term_to_binary(data)) end)

    {:noreply, state}
  end

  defp build_file_path(db_folder, key) do
    db_folder |> Path.join(to_string(key))
  end

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end
end
