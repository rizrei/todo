defmodule EtsKeyValue do
  @moduledoc """
  A simple key-value store using ETS for in-memory storage.
  """

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :ets.new(
      __MODULE__,
      [:named_table, :public, write_concurrency: true]
    )

    {:ok, nil}
  end

  def get(key) do
    case :ets.lookup(__MODULE__, key) do
      [{^key, val}] -> val
      [] -> nil
    end
  end

  def put(key, value) do
    :ets.insert(__MODULE__, {key, value})
  end
end
