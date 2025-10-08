defmodule Todo.ServerTest do
  use ExUnit.Case, async: false

  setup_all do
    list_name = "test_list"
    File.rm("./persist/#{list_name}")
    system_pid = start_supervised!(Todo.System)
    IO.inspect(system_pid)

    alice_pid = Todo.Cache.server_process(list_name)

    on_exit(fn ->
      Process.exit(system_pid, :normal)
    end)

    %{pid: alice_pid, list_name: list_name}
  end

  # setup do
  #   alice_pid = Todo.Cache.server_process("Alice's List")
  #   %{pid: alice_pid}
  # end

  describe "entries/2" do
    test "one entry present", %{pid: pid} do
      Todo.Server.add_entry(pid, %{date: ~D[2024-01-01], title: "Title1"})

      entries = [%{id: 1, date: ~D[2024-01-01], title: "Title1"}]

      assert ^entries = Todo.Server.entries(pid, ~D[2024-01-01])
    end
  end

  describe "add_entry/2" do
    test "create new entry", %{pid: pid, list_name: list_name} do
      Todo.Server.add_entry(pid, %{date: ~D[2024-01-02], title: "Title2"})

      state =
        {
          list_name,
          %Todo.List{
            next_id: 3,
            entries: %{
              1 => %{id: 1, date: ~D[2024-01-01], title: "Title1"},
              2 => %{id: 2, date: ~D[2024-01-02], title: "Title2"}
            }
          }
        }

      assert ^state = :sys.get_state(pid)
    end
  end

  describe "delete_entry/2" do
    test "one entry present", %{pid: pid, list_name: list_name} do
      Todo.Server.add_entry(pid, %{date: ~D[2024-01-01], title: "Title1"})
      Todo.Server.delete_entry(pid, 1)

      state =
        {
          list_name,
          %Todo.List{
            next_id: 3,
            entries: %{
              2 => %{id: 2, date: ~D[2024-01-02], title: "Title2"}
            }
          }
        }

      assert ^state = :sys.get_state(pid)
    end
  end
end
