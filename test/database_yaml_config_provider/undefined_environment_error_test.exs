defmodule DatabaseYamlConfigProvider.UndefinedEnvironmentErrorTest do
  use ExUnit.Case, async: true

  alias DatabaseYamlConfigProvider.UndefinedEnvironmentError

  describe "message/1" do
    test "get message" do
      assert Exception.message(%UndefinedEnvironmentError{env: "testing"}) ==
               "Environment not defined in configuration: testing"
    end
  end
end
