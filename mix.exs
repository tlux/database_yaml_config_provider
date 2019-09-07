defmodule DatabaseYamlConfigProvider.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :database_yaml_config_provider,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: description(),
      deps: deps(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_apps: [:mix]],
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),

      # Docs
      name: "Database YAML Config Provider",
      source_url:
        "https://gitlab.i22.de/pakete/elixir/database_yaml_config_provider/blob/master/%{path}#L%{line}",
      homepage_url:
        "https://gitlab.i22.de/pakete/elixir/database_yaml_config_provider",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:yaml_elixir, "~> 2.4"}
    ]
  end

  defp description do
    "A config provider to load a database.yml file as Ecto configuration."
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitLab" =>
          "https://gitlab.i22.de/pakete/elixir/database_yaml_config_provider"
      }
    ]
  end
end
