defmodule MTProto.Session.HandlerSupervisor do
  alias MTProto.Session
  use Supervisor

  @moduledoc false
  @name MTProto.Session.HandlerSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def init(_) do
    children = [
      worker(MTProto.Session.Handler, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def pop(session_id, dc_id) do
    Supervisor.start_child(@name, [session_id, dc_id])
  end

  def drop(session_id) do
    session = Session.get(session_id)
    Supervisor.terminate_child @name, session.listener
  end
end
