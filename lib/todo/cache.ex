defmodule Todo.Cache do
  alias Todo.{Database, Server}
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  @impl true
  def init(_) do
    {:ok, %{}, {:continue, :start_database}}
  end

  @impl true
  def handle_continue(:start_database, state) do
    Database.start()
    {:noreply, state}
  end

  @impl true
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = Server.start(todo_list_name)
        todo_servers = Map.put(todo_servers, todo_list_name, new_server)
        {:reply, new_server, todo_servers}
    end
  end
end

# {:ok, cache_pid} = Todo.Cache.start
# alice_pid = Todo.Cache.server_process(cache_pid, "Alice")
# Todo.Server.entries(alice_pid, ~D[2024-01-01])
# Todo.Server.add_entry(alice_pid, %{date: ~D[2024-01-01], title: "Title1"})
# Todo.Server.delete_entry(alice_pid, 3)
