defmodule Todo.DatabaseWorker do
  @moduledoc """
  A worker process responsible for storing and retrieving todo list data from the filesystem.
  """

  use GenServer
  require Logger

  @spec start_link(String.t()) :: {:ok, pid()} | {:error, term()}
  def start_link(db_folder) do
    GenServer.start_link(__MODULE__, db_folder)
  end

  @spec get(pid, String.t()) :: term()
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @spec store(pid, String.t(), term()) :: :ok
  def store(pid, key, data) do
    GenServer.call(pid, {:store, key, data})
  end

  #### Callbacks

  @impl true
  def init(db_folder) do
    Logger.info("Starting database worker")
    {:ok, %{db_folder: db_folder}}
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
  def handle_call({:store, key, data}, _from, %{db_folder: db_folder} = state) do
    build_file_path(db_folder, key) |> File.write!(:erlang.term_to_binary(data))

    {:reply, :ok, state}
  end

  defp build_file_path(db_folder, key) do
    db_folder |> Path.join(to_string(key))
  end
end
