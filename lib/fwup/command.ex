defmodule Fwup.Command do
  @moduledoc """
  Execute one off fwup commands
  """

  @doc """
  Get metadata from the specified fwup file

  Options

  * `:key_to_atom` - Convert metadata keys from strings to atoms, replaces "-" with "_"
  """
  @spec metadata(Path.t(), keyword()) :: {:ok, map()} | {:error, binary()}
  def metadata(path, opts \\ []) do
    case cmd(["-i", path, "-m"]) do
      {res, 0} ->
        {:ok, Fwup.Metadata.parse(res, opts)}

      {res, _} ->
        {:error, res}
    end
  end

  @spec cmd([binary]) :: {binary(), non_neg_integer}
  defp cmd(args) do
    System.cmd(Fwup.exe(), args)
  end
end
