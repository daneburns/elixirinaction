defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.auto_id,
        entry
      )

    %TodoList{todo_list | entries: new_entries, auto_id: todo_list.auto_id + 1}
  end

  def update_entry(todo_list, entry_id, updater_fun) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end
end

defmodule TodoList.CsvImporter do
  def filter_newlines(string) do
    case String.contains?(string, "\n") do
      true -> String.trim(string)
      _ -> string
    end
  end

  def makeEntry(string) do
    todo = String.split(string, ",")
    [date, title] = todo
    %{date: date, title: title}
  end

  def import(csvPath) do
    File.stream!(csvPath)
    |> Stream.map(&filter_newlines(&1))
    |> Stream.map(&makeEntry(&1))
    |> TodoList.new()
  end
end

TodoList.CsvImporter.import("./data/testData.csv")
