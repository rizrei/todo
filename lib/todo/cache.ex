defmodule Todo.Cache do
  alias Todo.Database
  use GenServer

  def start() do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  @impl true
  def init(_) do
    Database.start()
    {:ok, %{}}
  end

  @impl true
  def handle_call({:server_process, todo_list_name}, _, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        todo_servers = Map.put(todo_servers, todo_list_name, new_server)
        {:reply, new_server, todo_servers}
    end
  end
end
