defmodule Todo.Cache do
  @moduledoc """
  Manages `Todo.Server` processes by name, starting new ones on demand and caching them for reuse.
  """

  use DynamicSupervisor
  require Logger

  @spec start_link(any) :: {:ok, pid()} | {:error, any()}
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    Logger.info("Starting to-do cache")
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec server_process(String.t()) :: pid()
  def server_process(todo_list_name) do
    existing_server_process(todo_list_name) || new_server_process(todo_list_name)
  end

  defp existing_server_process(todo_list_name) do
    Todo.Server.whereis(todo_list_name)
  end

  defp new_server_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(__MODULE__, {Todo.Server, todo_list_name})
  end
end
