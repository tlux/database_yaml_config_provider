# Database YAML Config Provider

An Elixir 1.9+ config provider to load a Rails style database.yml file with the 
following structure when booting up the application. 

```yaml
production:
  adapter: postgresql
  database: testdb
  username: testuser
  password: myPa$sw0rd
  host: pgsqlhost
  port: 5432
```

The primary intention of this library is to simplify the migration process from 
a Rails app to Phoenix Framework.

## Prerequisites

* Elixir >= 1.9

## Installation

```elixir
def deps do
  [
    {:database_yaml_config_provider,
     git: "git@gitlab.i22.de:pakete/elixir/database_yaml_config_provider.git",
     tag: "v0.1.0",
     only: :prod}
    }
  ]
end
```

## Usage

You need to register this `DatabaseYamlConfigProvider` as config provider in
the releases section of your mix.exs file.

```elixir
releases: [
  my_app: [
    config_providers: [
      {DatabaseYamlConfigProvider,
       repo: MyApp.Repo,
       path: "/production/shared/config/database.yml"}
    ],
    ...
  ]
]
```

By default, this config provider expects an `ENV` environment variable that
contains the current hosting environment name to be present when booting the
application.

Alternatively, you can set the environment directly when defining the config
provider.

```elixir
{DatabaseYamlConfigProvider,
 repo: MyApp.Repo,
 path: "/production/shared/config",
 env: "production"}
```

Or you can speficy another env var containing the particular hosting
environment on application startup:

```elixir
{DatabaseYamlConfigProvider,
 repo: MyApp.Repo,
 path: "/production/shared/config",
 env: {:system, "RAILS_ENV"}}
```

The same works for the location of the database file. You can specify an env
var containing the path to a folder that contains the database.yml file:

```elixir
{DatabaseYamlConfigProvider, 
 repo: MyApp.Repo,
 path: {:system, "RELEASE_CONFIG_PATH"}}
```

When the filename deviates from database.yml you can customize it, too:

```elixir
{DatabaseYamlConfigProvider,
 repo: MyApp.Repo,
 path: {:system, "RELEASE_CONFIG_PATH", "my_custom_database.yml"}}
```

## Docs

Documentation can be generated with
[ExDoc](https://github.com/elixir-lang/ex_doc).
