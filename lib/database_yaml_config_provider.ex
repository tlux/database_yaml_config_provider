defmodule DatabaseYamlConfigProvider do
  @moduledoc """
  Documentation for DatabaseYamlConfigProvider.
  """

  @behaviour Config.Provider

  alias DatabaseYamlConfigProvider.AdapterMismatchError
  alias DatabaseYamlConfigProvider.InvalidFileFormatError
  alias DatabaseYamlConfigProvider.UndefinedEnvironmentError

  @adapters %{
    "mysql" => [Ecto.Adapters.MySQL, Ecto.Adapters.MyXQL],
    "postgresql" => [Ecto.Adapters.Postgres]
  }

  @impl true
  def init(opts) do
    path = Keyword.fetch!(opts, :path)
    repo = Keyword.fetch!(opts, :repo)
    otp_app = Keyword.fetch!(repo.config(), :otp_app)
    env = Keyword.get(opts, :env, {:system, "ENV"})
    %{repo: repo, otp_app: otp_app, path: path, env: env}
  end

  @impl true
  def load(config, opts) do
    {:ok, _} = Application.ensure_all_started(:yaml_elixir)

    env = resolve_env(opts.env)
    path = resolve_path(opts.path)
    config_data = fetch_config!(path, env)
    validate_adapter!(opts.repo, config_data["adapter"])

    Config.Reader.merge(config, [
      {opts.otp_app,
       [
         {opts.repo,
          [
            database: config_data["database"],
            hostname: config_data["host"],
            password: config_data["password"],
            port: config_data["port"],
            username: config_data["username"]
          ]}
       ]}
    ])
  end

  defp fetch_config!(path, env) do
    path
    |> read_config()
    |> validate_config!(env)
  end

  defp read_config(path) do
    path
    |> resolve_path()
    |> Path.expand()
    |> YamlElixir.read_from_file!()
  end

  defp validate_config!(config_data, env) when is_map(config_data) do
    case Map.fetch(config_data, env) do
      {:ok, env_config_data} -> env_config_data
      :error -> raise UndefinedEnvironmentError, env: env
    end
  end

  defp validate_config!(config_data, _env) do
    raise InvalidFileFormatError, data: config_data
  end

  defp validate_adapter!(repo, configured_name) do
    adapter = repo.__adapter__()

    unless valid_adapter?(adapter, configured_name) do
      raise AdapterMismatchError,
        adapter: adapter,
        configured_name: configured_name,
        repo: repo
    end

    :ok
  end

  defp valid_adapter?(adapter, configured_name) do
    case Map.fetch(@adapters, configured_name) do
      {:ok, permitted_adapters} -> adapter in permitted_adapters
      _ -> false
    end
  end

  defp resolve_path({:system, varname, filename}) do
    varname
    |> System.fetch_env!()
    |> Path.join(filename)
  end

  defp resolve_path(term), do: resolve_env(term)

  defp resolve_env({:system, varname}) do
    System.fetch_env!(varname)
  end

  defp resolve_env(term), do: term
end
