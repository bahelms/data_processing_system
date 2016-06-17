use Mix.Config

config :logger, level: :info

config :data_processing_system, DPS.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "dps",
  username: "postgres",
  password: "postgres",
  hostname: System.get_env("DB_HOSTNAME") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
