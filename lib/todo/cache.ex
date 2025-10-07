defmodule Todo.Cache do
  require Logger

  @moduledoc """
  Manages `Todo.Server` processes by name, starting new ones on demand and caching them for reuse.
  """

  alias Todo.{Database, Server}
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
  end

  @impl true
  def init(_) do
    Logger.info("Starting to-do cache")
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

# Supervisor.start_link([{Todo.Cache, nil}], strategy: :one_for_one)
# alice_pid = Todo.Cache.server_process("Alice's List")
# bob_pid = Todo.Cache.server_process("Alice's List")
# Todo.Server.entries(alice_pid, ~D[2024-01-01])
# Todo.Server.add_entry(alice_pid, %{date: ~D[2024-01-01], title: "Title1"})
# Todo.Server.delete_entry(alice_pid, 3)
# Process.whereis(Todo.Cache) |> Process.exit(:kill) # пример убийства процесса
