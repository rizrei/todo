defmodule Todo.List do
  @moduledoc false

  defstruct next_id: 1, entries: %{}

  @type new_entry :: %{data: Calendar.date(), title: String.t()}
  @type entry :: %{id: pos_integer(), data: Calendar.date(), title: String.t()}
  @type entries :: %{pos_integer() => entry()}
  @type todo_list :: %Todo.List{next_id: pos_integer(), entries: entries()}
  @type updater_fun :: (fun() -> {:ok, entry()} | {:error, any()})

  @spec new([new_entry()]) :: todo_list()
  def new(entries \\ []) do
    Enum.reduce(entries, %Todo.List{}, &add_entry(&2, &1))
  end

  @spec add_entry(todo_list(), new_entry()) :: todo_list()
  def add_entry(%Todo.List{entries: entries, next_id: next_id} = todo_list, entry) do
    new_entry = Map.put(entry, :id, next_id)
    new_entries = Map.put(entries, next_id, new_entry)

    %Todo.List{todo_list | entries: new_entries, next_id: next_id + 1}
  end

  @spec fetch_entry(todo_list(), pos_integer()) :: {:ok, entry()} | :error
  def fetch_entry(%Todo.List{entries: entries}, entry_id) do
    Map.fetch(entries, entry_id)
  end

  @spec entries(todo_list(), Calendar.date()) :: list(entry()) | []
  def entries(%Todo.List{entries: entries}, date) do
    entries
    |> Map.values()
    |> Enum.filter(&(&1.date == date))
  end

  @spec update_entry(todo_list(), pos_integer(), updater_fun()) ::
          {:ok, todo_list()} | {:error, any()}
  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        {:error, todo_list}

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        {:ok, %Todo.List{todo_list | entries: new_entries}}
    end
  end

  @spec update_entry(todo_list(), entry()) :: {:ok, todo_list()} | {:error, any()}
  def update_entry(todo_list, %{} = entry) do
    update_entry(todo_list, entry.id, fn _ -> entry end)
  end

  @spec delete_entry(todo_list(), pos_integer()) :: todo_list()
  def delete_entry(todo_list, entry_id) do
    %Todo.List{todo_list | entries: Map.delete(todo_list.entries, entry_id)}
  end
end
