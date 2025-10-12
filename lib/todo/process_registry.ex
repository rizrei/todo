defmodule Todo.ProcessRegistry do
  @moduledoc """
  A registry for managing process names and their associated PIDs using Elixir's built-in `Registry`.
  """

  def start_link do
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
