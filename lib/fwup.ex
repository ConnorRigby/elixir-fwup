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

  @doc """
  Stream a firmware image to the device

  Options

  * `:name` - register the started GenServer under this name (defaults to Fwup.Stream)
  * `:fwup_env` - the OS environment to pass to fwup
  """
  def stream(pid, args, opts \\ []) do
    all_opts =
      opts
      |> Keyword.put_new(:name, Fwup.Stream)
      |> Keyword.put(:cm, pid)
      |> Keyword.put(:fwup_args, args)

    Fwup.Stream.start_link(all_opts)
  end

  defdelegate send_chunk(pid, chunk),
    to: Fwup.Stream
end
