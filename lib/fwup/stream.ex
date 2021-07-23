defmodule Fwup.Stream do
  @moduledoc """
  Process wrapper around the `fwup` port.
  Should be used with `--framing`
  """
  use GenServer

  @typedoc """
  GenServer options

  * `:name` - the name of the GenServer
  * `:cm` - where to send fwup messages
  * `:fwup_args` - arguments to pass to fwup
  """
  @type options() :: [name: atom(), cm: pid(), fwup_args: [String.t()]]

  @doc """
  Start a FWUP stream

  ## Warning
  By default will create a `global` named process. This means that ideally
  you can not open two streams at once.
  """
  @spec start_link(options()) :: GenServer.on_start()
  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args, name: init_args[:name])
  end

  @deprecated "Use Fwup.Stream.start_link/1 instead"
  def start_link(cm, args, opts \\ [name: __MODULE__]) do
    init_args = [cm: cm, fwup_args: args] ++ opts
    start_link(init_args)
  end

  @doc "Send a chunk to FWUP."
  def send_chunk(fwup, chunk) do
    GenServer.call(fwup, {:send_chunk, chunk})
  end

  def init(args) do
    fwup_exe = Fwup.exe()

    port_args = [
      {:args, ["--framing", "--exit-handshake" | args[:fwup_args]]},
      :use_stdio,
      :binary,
      :exit_status,
      {:packet, 4}
    ]

    port = Port.open({:spawn_executable, fwup_exe}, port_args)
    {:ok, %{port: port, cm: args[:cm]}}
  end

  def terminate(_, state) do
    if state.port && Port.info(state.port) do
      Port.close(state.port)
    end
  end

  def handle_call({:send_chunk, chunk}, _from, state) do
    true = Port.command(state.port, chunk)
    {:reply, :ok, state}
  end

  def handle_info({_port, {:data, <<"PR", progress::16>>}}, state) do
    dispatch(state, {:progress, progress})
    {:noreply, state}
  end

  def handle_info({_port, {:data, <<"WN", code::16, message::binary>>}}, state) do
    dispatch(state, {:warning, code, message})
    {:noreply, state}
  end

  def handle_info({port, {:data, <<"ER", code::16, message::binary>>}}, state) do
    dispatch(state, {:error, code, message})
    _ = Port.close(port)
    {:stop, message, %{state | port: nil}}
  end

  def handle_info({port, {:data, <<"OK", code::16, message::binary>>}}, state) do
    dispatch(state, {:ok, code, message})
    _ = Port.close(port)
    {:stop, :normal, %{state | port: nil}}
  end

  def handle_info({_port, {:exit_status, status}}, state) do
    {:stop, {:error, {:unexpected_exit, status}}, %{state | port: nil}}
  end

  defp dispatch(%{cm: cm}, msg), do: send(cm, {:fwup, msg})
end
