defmodule Todo.Server do
  @moduledoc """
  A server process that manages a single todo list, providing an interface for adding, deleting,
  and querying todo entries. It persists the todo list using `Todo.Database`.
  """

  alias Todo.Database
  use GenServer

  def start(todo_list_name) do
    GenServer.start_link(__MODULE__, todo_list_name)
  end

  def add_entry(todo_server, new_entry) do
    GenServer.cast(todo_server, {:add_entry, new_entry})
  end

  def delete_entry(todo_server, entry_id) do
    GenServer.cast(todo_server, {:delete_entry, entry_id})
  end

  def entries(todo_server, date) do
    GenServer.call(todo_server, {:entries, date})
  end

  #### Callbacks

  @impl true
  def init(name) do
    {:ok, {name, nil}, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, {name, nil}) do
    {:noreply, {name, Database.get(name) || Todo.List.new()}}
  end

  @impl true
  def handle_call({:entries, date}, _from, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

  @impl true
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_todo_list = Todo.List.add_entry(todo_list, new_entry)
    Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end

  @impl true
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_todo_list = Todo.List.delete_entry(todo_list, entry_id)
    Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}}
  end
end

# Todo.Cache.start()
# {:ok, pid} = Todo.Server.start()
# Todo.Server.delete_entry(pid, 1)
# Todo.Server.entries(pid, ~D[2024-01-01])
# Todo.Server.add_entry(pid, %{date: ~D[2024-01-01], title: "Title1"})
# Todo.Server.add_entry(pid, %{date: ~D[2024-01-01], title: "Title2"})
# Todo.Server.add_entry(pid, %{date: ~D[2024-01-02], title: "Title3"})
