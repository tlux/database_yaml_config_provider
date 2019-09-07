defmodule DatabaseYamlConfigProviderTest do
  use ExUnit.Case, async: false

  alias DatabaseYamlConfigProvider.AdapterMismatchError
  alias DatabaseYamlConfigProvider.InvalidFileFormatError
  alias DatabaseYamlConfigProvider.UndefinedEnvironmentError

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

    test "load with env from env var" do
      System.put_env("TEST_APP_ENV", "staging")
      on_exit(fn -> System.delete_env("TEST_APP_ENV") end)

      opts =
        DatabaseYamlConfigProvider.init(
          path: "test/fixtures/database.yml",
          repo: MySQLRepo,
          env: {:system, "TEST_APP_ENV"}
        )

      assert DatabaseYamlConfigProvider.load(@config, opts) == [
               database_yaml_config_provider: [
                 {:ecto_repos, [MySQLRepo, PostgresRepo]},
                 {MySQLRepo,
                  [
                    database: "testdb",
                    hostname: "mysqlhost",
                    password: "testpw",
                    port: 3306,
                    username: "testuser"
                  ]}
               ]
             ]
    end

    test "load with path from env var" do
      System.put_env("TEST_CONFIG_PATH", "test/fixtures/database.yml")
      on_exit(fn -> System.delete_env("TEST_CONFIG_PATH") end)

      opts =
        DatabaseYamlConfigProvider.init(
          path: {:system, "TEST_CONFIG_PATH"},
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

    test "load with filename and dir from env var" do
      System.put_env("TEST_CONFIG_DIR", "test/fixtures")
      on_exit(fn -> System.delete_env("TEST_CONFIG_DIR") end)

      opts =
        DatabaseYamlConfigProvider.init(
          path: {:system, "TEST_CONFIG_DIR", "database.yml"},
          repo: MySQLRepo,
          env: "staging"
        )

      assert DatabaseYamlConfigProvider.load(@config, opts) == [
               database_yaml_config_provider: [
                 {:ecto_repos, [MySQLRepo, PostgresRepo]},
                 {MySQLRepo,
                  [
                    database: "testdb",
                    hostname: "mysqlhost",
                    password: "testpw",
                    port: 3306,
                    username: "testuser"
                  ]}
               ]
             ]
    end

    test "error when file not found" do
      opts =
        DatabaseYamlConfigProvider.init(
          path: "test/fixtures/not_found.yml",
          repo: PostgresRepo,
          env: "production"
        )

      assert_raise YamlElixir.FileNotFoundError, fn ->
        DatabaseYamlConfigProvider.load(@config, opts)
      end
    end

    test "error when file not valid YAML" do
      opts =
        DatabaseYamlConfigProvider.init(
          path: "test/fixtures/invalid_database.yml",
          repo: PostgresRepo,
          env: "production"
        )

      assert_raise InvalidFileFormatError, fn ->
        DatabaseYamlConfigProvider.load(@config, opts)
      end
    end

    test "error when env not found in file" do
      opts =
        DatabaseYamlConfigProvider.init(
          path: "test/fixtures/database.yml",
          repo: PostgresRepo,
          env: "testing"
        )

      assert_raise UndefinedEnvironmentError, fn ->
        DatabaseYamlConfigProvider.load(@config, opts)
      end
    end

    test "error when configured adapter mismatches Ecto adapter" do
      opts =
        DatabaseYamlConfigProvider.init(
          path: "test/fixtures/database.yml",
          repo: MySQLRepo,
          env: "production"
        )

      assert_raise AdapterMismatchError, fn ->
        DatabaseYamlConfigProvider.load(@config, opts)
      end
    end
  end
end
