defmodule Todo.Server do
  require Logger

  @moduledoc """
  A server process that manages a single todo list, providing an interface for adding, deleting,
  and querying todo entries. It persists the todo list using `Todo.Database`.
  """

  alias Todo.Database
  use Agent, restart: :temporary

  def start_link(name) do
    Agent.start_link(
      fn ->
        Logger.info("Starting todo server for #{name}")
        {name, Database.get(name) || Todo.List.new()}
      end,
      name: via_tuple(name)
    )
  end

  def entries(pid, date) do
    Agent.get(
      pid,
      fn {_name, todo_list} -> Todo.List.entries(todo_list, date) end
    )
  end

  def add_entry(pid, new_entry) do
    Agent.cast(pid, fn {name, todo_list} ->
      new_list = Todo.List.add_entry(todo_list, new_entry)
      Database.store(name, new_list)
      {name, new_list}
    end)
  end

  def delete_entry(pid, entry_id) do
    Agent.cast(pid, fn {name, todo_list} ->
      new_list = Todo.List.delete_entry(todo_list, entry_id)
      Database.store(name, new_list)
      {name, new_list}
    end)
  end

  defp via_tuple(name) do
    {:via, Registry, {Todo.ProcessRegistry, {__MODULE__, name}}}
  end
end
