defmodule Todo.Server do
  @moduledoc """
  A server process that manages a single todo list, providing an interface for adding, deleting,
  and querying todo entries. It persists the todo list using `Todo.Database`.
  """

  use GenServer, restart: :temporary
  require Logger
  alias Todo.Database

  @timeout :timer.minutes(1)

  @spec start_link(String.t()) :: {:ok, pid()} | {:error, term()}
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: {:global, {__MODULE__, name}})
  end

  @spec add_entry(pid(), map()) :: :ok
  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  @spec delete_entry(pid(), integer()) :: :ok
  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  @spec entries(pid(), Date.t()) :: list()
  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  @spec whereis(String.t()) :: pid() | nil
  def whereis(name) do
    case :global.whereis_name({__MODULE__, name}) do
      :undefined -> nil
      pid -> pid
    end
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
end
