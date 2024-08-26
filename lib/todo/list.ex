defmodule Todo.List do
  defstruct next_id: 1, entries: %{}

  @type new_entry :: %{data: Calendar.date(), title: String.t()}
  @type entry :: %{id: pos_integer(), data: Calendar.date(), title: String.t()}
  @type entries :: %{pos_integer() => entry()}
  @type todo_list :: %Todo.List{next_id: pos_integer(), entries: entries()}
  @type updater_fun :: (fun() -> {:ok, entry()} | {:error, any()})

  @spec new(list(new_entry())) :: todo_list()
  def new(entries \\ []) do
    entries
    |> Enum.reduce(
      %Todo.List{},
      fn entry, todo_list -> add_entry(todo_list, entry) end
    )
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

  @spec add_entry(todo_list(), new_entry()) :: todo_list()
  def add_entry(%Todo.List{entries: entries, next_id: next_id} = todo_list, entry) do
    new_entry = Map.put(entry, :id, next_id)
    new_entries = Map.put(entries, next_id, new_entry)

    %Todo.List{todo_list | entries: new_entries, next_id: next_id + 1}
  end

  @spec update_entry(entry(), updater_fun()) :: {:ok, entry()} | {:error, any()}
  def update_entry(entry, updater_fun) do
    updater_fun.(entry)
  end

  @spec update_entry(todo_list(), pos_integer(), updater_fun()) ::
          {:ok, todo_list()} | {:error, any()}
  def update_entry(todo_list, entry_id, updater_fun) do
    with {:ok, old_entry} <- fetch_entry(todo_list, entry_id),
         {:ok, new_entry} <- update_entry(old_entry, updater_fun) do
      new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
      {:ok, %Todo.List{todo_list | entries: new_entries}}
    else
      _ -> {:error, todo_list}
    end
  end

  @spec delete_entry(todo_list(), pos_integer()) :: todo_list()
  def delete_entry(%Todo.List{entries: entries} = todo_list, entry_id) do
    %Todo.List{todo_list | entries: Map.delete(entries, entry_id)}
  end
end
