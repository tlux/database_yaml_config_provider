defmodule DatabaseYamlConfigProvider.AdapterMismatchErrorTest do
  use ExUnit.Case, async: true

  alias DatabaseYamlConfigProvider.AdapterMismatchError

  describe "message/1" do
    test "get message" do
      assert Exception.message(%AdapterMismatchError{
               adapter: Ecto.Adapters.Postgres,
               configured_name: "postgresql",
               repo: MySQLRepo
             }) ==
               ~s(The configuration specifies "postgresql" as adapter, ) <>
                 ~s(but the repo MySQLRepo specifies Ecto.Adapters.Postgres.)
    end
  end
end
