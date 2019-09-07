defmodule DatabaseYamlConfigProvider.InvalidFileFormatError do
  @moduledoc """
  An error that raises when the parsed config file has an invalid format.
  """

  defexception [:data]

  @impl true
  def message(exception) do
    "Invalid file format: #{inspect(exception.data)}"
  end
end
