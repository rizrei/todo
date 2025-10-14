# Todo
A small Elixir application for managing todo lists. Stores lists in memory and can persist them to disk via a pool of worker processes.

This project is the result of working through the book "Elixir in Action" (3rd Edition) by Saša Jurić.


## Features

- Add, update, and delete tasks
- Query tasks by date
- In-memory list management with optional filesystem persistence
- Process-per-list model (Todo.Server) managed by Todo.Cache
- Worker pool for disk IO (Todo.Database / Todo.DatabaseWorker)


### Installation

1. Install dependencies and compile:

```sh
mix deps.get
mix deps.compile
```

2. Run tests:
```sh
mix test
```

3. Start interactive session:
```sh
iex -S mix
```


### Usage

Example usage in IEx:

```elixir
alice_pid = Todo.Cache.server_process("Alice's List")
Todo.Server.add_entry(alice_pid, %{date: ~D[2025-01-01], title: "Write documentation"})
Todo.Server.entries(alice_pid, ~D[2025-01-01])
Todo.Server.delete_entry(alice_pid, 1)
```


Example usage in shell:
```sh
curl -d "" "http://localhost:5454/add_entry?list=bob&date=2018-12-19&title=Shopping"
curl "http://localhost:5454/entries?list=bob&date=2018-12-19"
curl -X DELETE "http://localhost:5454/entries/1?list=bob" -v 
```

## License

This project is licensed under the MIT License.
