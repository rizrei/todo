defmodule Todo.Application do
  @moduledoc """
  The main application module that starts the Todo system supervision tree.
  """

  use Application

  def start(_, _) do
    Todo.System.start_link()
  end
end
