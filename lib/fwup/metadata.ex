defmodule Fwup.Metadata do
  @moduledoc """
  Fwup Metadata
  """

  @doc """
  Parse metadata string to a map

  Options

  * `:key_to_atom` - Convert metadata keys from strings to atoms, replaces "-" with "_"
  """
  @spec parse(binary(), keyword()) :: map()
  def parse(str, opts \\ []) do
    str
    |> String.split("\n", trim: true)
    |> Enum.map(fn entry ->
      [key, val] = String.split(entry, "=", parts: 2, trim: true)

      key =
        key
        |> String.trim_leading("meta-")

      key =
        if opts[:keys_to_atoms] do
          key
          |> String.replace("-", "_")
          |> String.to_atom()
        else
          key
        end

      val =
        val
        |> String.trim("\"")

      {key, val}
    end)
    |> Map.new()
  end
end
