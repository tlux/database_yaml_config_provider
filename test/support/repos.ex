defmodule MySQLRepo do
  use Ecto.Repo,
    otp_app: :database_yaml_config_provider,
    adapter: Ecto.Adapters.MyXQL
end

defmodule PostgresRepo do
  use Ecto.Repo,
    otp_app: :database_yaml_config_provider,
    adapter: Ecto.Adapters.Postgres
end
