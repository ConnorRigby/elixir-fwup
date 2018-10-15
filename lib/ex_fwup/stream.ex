defmodule ExFwup.Stream do
  use GenServer

  def test do
    fw = "/home/connor/farmbot/os/os/_build/rpi3/dev/nerves/images/farmbot.fw"
    [[dev, _size_bytes]] = ExFwup.get_devices()
    args = ["-a", "-i", fw, "-t", "complete", "-d", dev, "--framing"]
    start_link(self(), args)
  end

  def stream_test do
    # Doesn't work yet
    fw = "/home/connor/farmbot/os/os/_build/rpi3/dev/nerves/images/farmbot.fw"
    [[dev, _size_bytes]] = ExFwup.get_devices()
    args = ["-a", "-i", "-", "-t", "complete", "-d", dev, "--framing"]
    {:ok, pid} = start_link(self(), args)
    File.stream!(fw, [:bytes], 2048)
    |> Stream.map(fn(chunk) ->
      send_chunk(pid, <<byte_size(chunk) :: size(32)>> <> chunk)
    end)
    |> Stream.run()
  end

  @doc "Start a FWUP stream."
  def start_link(cm, args, opts \\  []) do
    GenServer.start_link(__MODULE__, [cm | args], opts)
  end

  @doc "Send a chunk to FWUP."
  def send_chunk(fwup, chunk) do
    GenServer.call(fwup, {:send_chunk, chunk})
  end

  def init([cm | args]) do
    fwup_exe = ExFwup.exe()
    port_args = [
      {:args, args}, :use_stdio, :binary, :exit_status, {:packet, 4}
    ]
    port = Port.open({:spawn_executable, fwup_exe}, port_args)
    {:ok, %{port: port, cm: cm}}
  end

  def handle_call({:send_chunk, chunk}, _from, state) do
    true = Port.command(state.port, chunk)
    {:reply, :ok, state}
  end

  def handle_info({_port, {:data, <<"PR", progress::16>>}}, state) do
    IO.write("Progress: #{progress}%\r")
    {:noreply, state}
  end

  def handle_info({_port, {:data, <<"ER", code::16, message :: binary>>}}, state) do
    IO.puts [IO.ANSI.red(), "Error #{code} ", message, IO.ANSI.normal()]
    {:noreply, state}
  end

  def handle_info({_port, {:data, <<"WN", code::16, message :: binary>>}}, state) do
    IO.puts [IO.ANSI.yellow(), "Error #{code} ", message, IO.ANSI.normal()]
    {:noreply, state}
  end

  def handle_info({_port, {:data, <<"OK", code::16, message :: binary>>}}, state) do
    IO.puts [IO.ANSI.green(), "Error #{code} ", message, IO.ANSI.normal()]
    {:noreply, state}
  end

  def handle_info({_port, {:exit_status, status}}, state) do
    {:stop, {:exit, status}, state}
  end
end
