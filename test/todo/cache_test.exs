defmodule Todo.CacheTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = Todo.Cache.start_link([])
    %{cache_pid: pid}
  end

  describe "server_process/2" do
    test "start 2 different todo server processes for each name", %{cache_pid: pid} do
      alice_pid = Todo.Cache.server_process("Alice")
      bob_pid = Todo.Cache.server_process("Bob")

      assert alice_pid != bob_pid
    end

    test "same pid for existing process", %{cache_pid: pid} do
      alice_pid = Todo.Cache.server_process("Alice")

      assert ^alice_pid = Todo.Cache.server_process("Alice")
    end
  end
end
