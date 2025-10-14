defmodule Todo.System do
  @moduledoc """
  Supervises the Todo application components, ensuring they are started and monitored.
  """

  use Supervisor

  @spec start_link() :: {:ok, pid()} | {:error, term()}
  def start_link do
    Supervisor.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    children = [
      # {Todo.Metrics, 5},
      Todo.Database,
      Todo.Cache,
      Todo.Web
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
