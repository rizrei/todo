defmodule TodoList.CsvImporter do
  @moduledoc """
  Utility module to import todo entries from a CSV file.
  """

  @type entry() :: %{data: Calendar.date(), title: String.t()}
  @spec import(String.t()) :: [entry()]
  def import(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn [date, title] ->
      %{date: Date.from_iso8601!(date), title: title}
    end)
    |> Enum.to_list()
  end
end
