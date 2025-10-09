defmodule Todo.Server do
  require Logger

  @moduledoc """
  A server process that manages a single todo list, providing an interface for adding, deleting,
  and querying todo entries. It persists the todo list using `Todo.Database`.
  """

  alias Todo.Database
  use GenServer

  def start_link(todo_list_name) do
    GenServer.start_link(__MODULE__, todo_list_name, name: via_tuple(todo_list_name))
  end

  def add_entry(todo_server_pid, new_entry) do
    GenServer.cast(todo_server_pid, {:add_entry, new_entry})
  end

  def delete_entry(todo_server_pid, entry_id) do
    GenServer.cast(todo_server_pid, {:delete_entry, entry_id})
  end

  def entries(todo_server_pid, date) do
    GenServer.call(todo_server_pid, {:entries, date})
  end

  #### Callbacks

  @impl true
  def init(name) do
    Logger.info("Starting todo server for #{name}")
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

  defp via_tuple(name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, name})
  end
end
