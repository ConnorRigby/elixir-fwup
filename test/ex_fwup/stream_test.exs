defmodule ExFwup.StreamTest do
  use ExUnit.Case
  alias ExFwup.TestSupport.Fixtures

  test "File.stream! into fwup" do
    {:ok, fw} = Fixtures.create_firmware("test_stream")
    dev = Path.join(Path.dirname(fw), "test_stream.img")
    args = ["-a", "-t", "complete", "-d", dev]
    {:ok, fwup} = ExFwup.stream(self(), args)

    File.stream!(fw, [:bytes], 4096)
    |> Stream.map(fn chunk ->
      ExFwup.send_chunk(fwup, chunk)
    end)
    |> Stream.run()

    refute_receive {:error, _code, _message}
    assert_receive {:progress, 100}
    assert_receive {:ok, 0, ""}
    assert File.exists?(dev)
  end

  test "Regular -i stream" do
    {:ok, fw} = Fixtures.create_firmware("regular")
    dev = Path.join(Path.dirname(fw), "regular.img")
    args = ["-a", "-i", fw, "-t", "complete", "-d", dev]
    {:ok, _} = ExFwup.stream(self(), args)
    refute_receive {:error, _code, _message}
    assert_receive {:progress, 100}
    assert_receive {:ok, 0, ""}
    assert File.exists?(dev)
  end
end
