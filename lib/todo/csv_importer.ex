defmodule TodoList.CsvImporter do
  @spec import(String.t()) :: list(%{data: Calendar.date(), title: String.t()})
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
