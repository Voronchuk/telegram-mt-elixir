defmodule MTProto.Session.Handler do
  use GenServer
  alias MTProto.TCP
  alias MTProto.TL.Build
  alias MTProto.Crypto
  alias MTProto.Registry

  def start(socket, crypto) do
     GenServer.start(__MODULE__, {socket, crypto}, [])
  end

  def init({socket, crypto}) do
    session_id = Crypto.rand_bytes(16)
    {:ok, %{socket: socket, sequence: 0, session_id: session_id, crypto: crypto}}
  end

  def handle_info({:recv, msg}, state) do
    IO.inspect msg
    {:noreply, state}
  end

  def handle_info({:send_plain, msg}, state) do
    seq = Map.get state, :sequence
    sock = Map.get state, :socket

    # Send message
    msg |> TCP.wrap(seq) |> TCP.send(sock)

    # Update handler state
    state = Map.put state, :sequence, seq + 1
    {:noreply, state}
  end

  def handle_info({:send, payload}, state) do
    seq = Map.get state, :sequence
    sock = Map.get state, :socket
    session_id = Map.get state, :session_id
    crypto = Map.get(state, :crypto) |> Registry.get

    auth_key = Map.get crypto, :auth_key
    server_salt = Map.get crypto, :server_salt

    # Encrypt and send message
    encrypted_msg = Crypto.encrypt_message(auth_key, server_salt, session_id, payload)
    encrypted_msg |> TCP.wrap(seq) |> TCP.send(sock)

    # Update handler state
    state = Map.put state, :sequence, seq + 1
    {:noreply, state}
  end

  def stop(pid) do
    GenServer.stop(pid)
  end
end
