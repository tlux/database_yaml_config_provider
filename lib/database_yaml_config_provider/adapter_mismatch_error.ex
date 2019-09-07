defmodule DatabaseYamlConfigProvider.AdapterMismatchError do
  defexception [:adapter, :configured_name, :repo]

  @impl true
  def message(exception) do
    "The configuration specifies #{inspect(exception.configured_name)} as " <>
      "adapter, but the repo #{inspect(exception.repo)} " <>
      "specifies #{inspect(exception.adapter)}."
  end
end
