defmodule ExFwup do
  def get_devices do
    {result, 0} = System.cmd("fwup", ["--detect"])
    result
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
  end

  def exe do
    System.find_executable("fwup")
  end
end
