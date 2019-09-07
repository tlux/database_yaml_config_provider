defmodule DatabaseYamlConfigProviderTest do
  use ExUnit.Case

  @config [
    database_yaml_config_provider: [
      ecto_repos: [MySQLRepo, PostgresRepo]
    ]
  ]

  describe "init/1" do
    test "success with repo, path and env" do
      assert DatabaseYamlConfigProvider.init(
               env: "testing",
               path: "test/fixtures/database.yml",
               repo: PostgresRepo
             ) == %{
               env: "testing",
               otp_app: :database_yaml_config_provider,
               path: "test/fixtures/database.yml",
               repo: PostgresRepo
             }
    end

    test "default env" do
      assert DatabaseYamlConfigProvider.init(
               path: "test/fixtures/database.yml",
               repo: PostgresRepo
             ) ==
               %{
                 env: {:system, "ENV"},
                 otp_app: :database_yaml_config_provider,
                 path: "test/fixtures/database.yml",
                 repo: PostgresRepo
               }
    end

    test "raise when path missing" do
      assert_raise KeyError, ~r/key :path not found/, fn ->
        DatabaseYamlConfigProvider.init(repo: PostgresRepo)
      end
    end

    test "raise when repo missing" do
      assert_raise KeyError, ~r/key :repo not found/, fn ->
        DatabaseYamlConfigProvider.init(path: "test/fixtures/database.yml")
      end
    end
  end

  describe "load/2" do
    test "load with env string" do
      opts =
        DatabaseYamlConfigProvider.init(
          path: "test/fixtures/database.yml",
          repo: PostgresRepo,
          env: "production"
        )

      assert DatabaseYamlConfigProvider.load(@config, opts) == [
               database_yaml_config_provider: [
                 {:ecto_repos, [MySQLRepo, PostgresRepo]},
                 {PostgresRepo,
                  [
                    database: "testdb",
                    hostname: "pgsqlhost",
                    password: "testpw",
                    port: 5432,
                    username: "testuser"
                  ]}
               ]
             ]
    end

    test "load with env from env var"

    test "load with path string"

    test "load with path from env var"

    test "error when file not found"

    test "error when file not valid YAML"

    test "error when env not found in file"

    test "error when configured adapter mismatches Ecto adapter"
  end
end
