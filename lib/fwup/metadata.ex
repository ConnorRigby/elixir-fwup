defmodule Fwup.Metadata do
  @moduledoc """
  Fwup Metadata
  """

  @supported_metadata_atoms %{
    "meta-product" => :product,
    "meta-description" => :description,
    "meta-version" => :version,
    "meta-author" => :author,
    "meta-platform" => :platform,
    "meta-architecture" => :architecture,
    "meta-vcs-identifier" => :vcs_identifier,
    "meta-misc" => :misc,
    "meta-creation-date" => :creation_date,
    "meta-fwup-version" => :fwup_version,
    "meta-uuid" => :uuid,
    "meta-nickname" => :nickname
  }

  @doc """
  Parse metadata string to a map

  Options

  * `:key_to_atom` - Convert metadata keys from strings to atoms, replaces "-" with "_"
  """
  @spec parse(binary(), keyword()) :: map()
  def parse(str, opts \\ []) do
    str
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn entry, acc ->
      [key, val] = String.split(entry, "=", parts: 2, trim: true)

      case parse_key(key, opts) do
        nil -> acc
        parsed_key -> Map.put(acc, parsed_key, String.trim(val, "\""))
      end
    end)
  end

  defp parse_key(string_key, opts) do
    if opts[:keys_to_atoms] do
      Map.get(@supported_metadata_atoms, string_key)
    else
      String.trim_leading(string_key, "meta-")
    end
  end
end
