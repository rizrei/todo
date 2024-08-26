defmodule Todo.ServerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = Todo.Server.start()
    %{pid: pid}
  end

  describe "entries/2" do
    test "one entry present", %{pid: pid} do
      Todo.Server.add_entry(pid, %{date: ~D[2024-01-01], title: "Title1"})

      entries = [%{id: 1, date: ~D[2024-01-01], title: "Title1"}]

      assert ^entries = Todo.Server.entries(pid, ~D[2024-01-01])
    end
  end

  describe "add_entry/2" do
    test "create new entry", %{pid: pid} do
      Todo.Server.add_entry(pid, %{date: ~D[2024-01-01], title: "Title1"})

      state = %Todo.List{
        next_id: 2,
        entries: %{
          1 => %{id: 1, date: ~D[2024-01-01], title: "Title1"}
        }
      }

      assert ^state = :sys.get_state(pid)
    end
  end

  describe "delete_entry/2" do
    test "one entry present", %{pid: pid} do
      Todo.Server.add_entry(pid, %{date: ~D[2024-01-01], title: "Title1"})
      Todo.Server.delete_entry(pid, 1)

      state = %Todo.List{
        next_id: 2,
        entries: %{}
      }

      assert ^state = :sys.get_state(pid)
    end
  end
end
