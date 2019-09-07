defmodule DatabaseYamlConfigProvider.AdapterMismatchError do
  @moduledoc """
  An error that raises when the adapter in the configuration file mismatches the
  adapter specified by the repo.
  """

  defexception [:adapter, :configured_name, :repo]

  @impl true
  def message(exception) do
    "The configuration specifies #{inspect(exception.configured_name)} as " <>
      "adapter, but the repo #{inspect(exception.repo)} " <>
      "specifies #{inspect(exception.adapter)}."
  end
end
