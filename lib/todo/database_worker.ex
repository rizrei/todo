defmodule Todo.DatabaseWorker do
  use GenServer

  def start(db_folder) do
    GenServer.start(__MODULE__, db_folder)
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  #### Callbacks

  @impl true
  def init(db_folder) do
    File.mkdir_p!(db_folder)
    {:ok, %{db_folder: db_folder}}
  end

  @impl true
  def handle_call({:get, key}, from, %{db_folder: db_folder} = state) do
    spawn(fn ->
      data =
        case build_file_path(db_folder, key) |> File.read() do
          {:ok, contents} -> :erlang.binary_to_term(contents)
          _ -> nil
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
end
