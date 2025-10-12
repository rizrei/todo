defmodule Todo.System do
  @moduledoc """
  Supervises the Todo application components, ensuring they are started and monitored.
  """

  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    children = [
      {Todo.Metrics, 5},
      Todo.ProcessRegistry,
      Todo.Database,
      Todo.Cache
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

# Todo.System.start_link([])
# [{worker_pid, _}] = Registry.lookup(Todo.ProcessRegistry, {Todo.DatabaseWorker, 1})
# Process.exit(worker_pid, :kill)
# alice_pid = Todo.Cache.server_process("Alice's List")
# bob_pid = Todo.Cache.server_process("Bob's List")
# Todo.Server.entries(alice_pid, ~D[2024-01-01])
# Todo.Server.add_entry(alice_pid, %{date: ~D[2024-01-01], title: "Title1"})
# Todo.Server.delete_entry(alice_pid, 3)
# Process.whereis(Todo.Cache) |> Process.exit(:kill) # пример убийства процесса
