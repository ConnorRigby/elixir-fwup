defmodule Fwup.StreamTest do
  use ExUnit.Case
  alias Fwup.TestSupport.Fixtures

  test "File.stream! into fwup" do
    {:ok, fw} = Fixtures.create_firmware("test_stream")
    dev = Path.join(Path.dirname(fw), "test_stream.img")
    args = ["-a", "-t", "complete", "-d", dev]
    {:ok, fwup} = Fwup.stream(self(), args, [])

    File.stream!(fw, [:bytes], 4096)
    |> Stream.map(fn chunk ->
      Fwup.send_chunk(fwup, chunk)
    end)
    |> Stream.run()

    refute_receive {:fwup, {:error, _code, _message}}
    assert_receive {:fwup, {:progress, 100}}
    assert_receive {:fwup, {:ok, 0, ""}}
    assert File.exists?(dev)
  end

  test "Regular -i stream" do
    {:ok, fw} = Fixtures.create_firmware("regular")
    dev = Path.join(Path.dirname(fw), "regular.img")
    args = ["-a", "-i", fw, "-t", "complete", "-d", dev]
    _ = Process.flag(:trap_exit, true)
    {:ok, pid} = Fwup.stream(self(), args, [])
    refute_receive {:fwup, {:error, _code, _message}}
    assert_receive {:fwup, {:progress, 100}}
    assert_receive {:fwup, {:ok, 0, ""}}
    assert_receive {:EXIT, ^pid, :normal}
    assert File.exists?(dev)
  end

  test "corrupt firmware stream" do
    {:ok, fw} = Fixtures.create_firmware("regular-to-currupt")
    {:ok, fw} = Fixtures.corrupt_firmware_file(fw, "currupted")
    dev = Path.join(Path.dirname(fw), "regular-to-currupt.img")
    args = ["-a", "-i", fw, "-t", "complete", "-d", dev]
    _ = Process.flag(:trap_exit, true)
    {:ok, pid} = Fwup.stream(self(), args, [])
    assert_receive {:fwup, {:error, 0, "Unrecognized archive format"}}
    assert_receive {:EXIT, ^pid, "Unrecognized archive format"}
  end
end
