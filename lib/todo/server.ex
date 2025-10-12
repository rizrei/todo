defmodule Todo.Server do
  @moduledoc """
  A server process that manages a single todo list, providing an interface for adding, deleting,
  and querying todo entries. It persists the todo list using `Todo.Database`.
  """

  use GenServer, restart: :temporary
  require Logger
  alias Todo.Database

  @timeout :timer.seconds(10)

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
    new_state = {name, Database.get(name) || Todo.List.new()}
    {:noreply, new_state, @timeout}
  end

  @impl true
  def handle_call({:entries, date}, _from, {_name, todo_list} = state) do
    reply = Todo.List.entries(todo_list, date)
    {:reply, reply, state, @timeout}
  end

  @impl true
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_todo_list = Todo.List.add_entry(todo_list, new_entry)
    Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}, @timeout}
  end

  @impl true
  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    new_todo_list = Todo.List.delete_entry(todo_list, entry_id)
    Database.store(name, new_todo_list)
    {:noreply, {name, new_todo_list}, @timeout}
  end

  @impl true
  def handle_info(:timeout, {name, todo_list}) do
    Logger.info("Stopping to-do server for #{name}")
    {:stop, :normal, {name, todo_list}}
  end

  defp via_tuple(name) do
    {:via, Registry, {Todo.ProcessRegistry, {__MODULE__, name}}}
  end
end
