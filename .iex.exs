IEx.configure(
  history_size: 50,
  width: 80,
  inspect: [
    pretty: true,
    limit: :infinity,
    width: 80
  ],
  colors: [
    syntax_colors: [
      number: :red,
      atom: :blue,
      string: :green,
      boolean: :magenta,
      nil: :magenta,
      list: :white
    ],
    eval_result: [:cyan, :bright],
    eval_error: [:red, :bright],
    eval_info: [:yellow, :bright],

  ],
  default_prompt:
    [
      :cyan, "%prefix",
      :yellow,"|💧|",
      :cyan, "%counter",
      " ",
      :yellow, "▶",
      :reset
    ]
    |> IO.ANSI.format()
    |> IO.chardata_to_string()
)
