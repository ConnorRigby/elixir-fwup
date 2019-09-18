defmodule Fwup do
  @moduledoc """
  Configurable embedded Linux firmware update creator and runner
  """

  @doc "Returns a list of `[\"/path/to/device\", byte_size]`"
  def get_devices do
    {result, 0} = System.cmd("fwup", ["--detect"])

    result
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
  end

  @doc "Returns the path to the `fwup` executable."
  def exe do
    System.find_executable("fwup") || raise("Could not find `fwup` executable.")
  end

  @doc "Stream firmware image to the device"
  defdelegate stream(pid, args, opts \\ [name: Fwup.Stream]), to: Fwup.Stream, as: :start_link

  defdelegate send_chunk(pid, chunk),
    to: Fwup.Stream
end
