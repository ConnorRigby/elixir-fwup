defmodule ExFwup.Stream do
  @moduledoc """
  Procses wrapper around the `fwup` port.
  Should be used with `--framing`
  """
  use GenServer

  @doc "Start a FWUP stream."
  def start_link(cm, args, opts \\ []) do
    GenServer.start_link(__MODULE__, [cm | args], opts)
  end

  @doc "Send a chunk to FWUP."
  def send_chunk(fwup, chunk) do
    GenServer.call(fwup, {:send_chunk, chunk})
  end

  def init([cm | args]) do
    fwup_exe = ExFwup.exe()

    port_args = [
      {:args, ["--framing" | args]},
      :use_stdio,
      :binary,
      :exit_status,
      {:packet, 4}
    ]

    port = Port.open({:spawn_executable, fwup_exe}, port_args)
    {:ok, %{port: port, cm: cm}}
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
    send(state.cm, {:progress, progress})
    {:noreply, state}
  end

  def handle_info({_port, {:data, <<"ER", code::16, message::binary>>}}, state) do
    send(state.cm, {:error, code, message})
    {:noreply, state}
  end

  def handle_info({_port, {:data, <<"WN", code::16, message::binary>>}}, state) do
    send(state.cm, {:warning, code, message})
    {:noreply, state}
  end

  def handle_info({_port, {:data, <<"OK", code::16, message::binary>>}}, state) do
    send(state.cm, {:ok, code, message})
    {:noreply, state}
  end

  def handle_info({_port, {:exit_status, 0}}, state) do
    {:stop, :normal, %{state | port: nil}}
  end

  def handle_info({_port, {:exit_status, status}}, state) do
    {:stop, {:exit, status}, %{state | port: nil}}
  end
end
