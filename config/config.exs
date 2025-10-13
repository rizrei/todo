import Config

config :todo,
  http_port: 5454,
  database_folder: "./persist",
  database_pool_size: 4

import_config "#{config_env()}.exs"
