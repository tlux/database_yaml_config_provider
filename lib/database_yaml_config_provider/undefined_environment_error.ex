defmodule DatabaseYamlConfigProvider.UndefinedEnvironmentError do
  @moduledoc """
  An error that raises when the config file does not contain an entry for the
  expected environment.
  """

  defexception [:env]

  @impl true
  def message(exception) do
    "Environment not defined in configuration: #{exception.env}"
  end
end
