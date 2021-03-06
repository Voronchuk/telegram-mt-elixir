defmodule MTProto.Session.Brain do
  alias MTProto.{Auth, Session}
  alias MTProto.Session.Handler
  require Logger

  @moduledoc false

  # Process plain messages
  def process(msg, session_id, :plain) do
    name = Map.get(msg, :name)

    case name do
      "resPQ" -> Auth.resPQ(msg, session_id)
      "server_DH_params_ok" -> Auth.server_DH_params_ok(msg, session_id)
      "server_DH_params_fail" -> Auth.server_DH_params_fail(msg, session_id)
      "dh_gen_ok" -> Auth.dh_gen_ok(msg, session_id)
      "dh_gen_fail" -> Auth.dh_gen_fail(msg, session_id)
      "dh_gen_retry" -> Auth.dh_gen_fail(msg, session_id)
      "error" -> handle_error(session_id, msg)
      _ ->
        Logger.debug "[MT][Brain] Unknow predicate : #{name}"
    end
  end

  # Process encrypted messages
  def process(msg, session_id, :encrypted) do
    session = Session.get(session_id)
    name = Map.get(msg, :name)

    # Process RPC
    case name do
      "rpc_result" ->
        result = Map.get msg, :result
        name = result |> Map.get(:name)

        case name do
          "auth.sentCode" ->
            hash = Map.get result, :phone_code_hash
            Session.update(session_id, phone_code_hash: hash)
          "auth.authorization" ->
            Logger.debug "Session #{session_id} is now logged in !"
            user_id = Map.get(result, :user) |> Map.get(:id)
            Session.update(session_id, user_id: user_id)
          "rpc_error" -> handle_rpc_error(session_id, result)
          _ -> :noop
        end

        # ACK
        msg_ids = [Map.get(msg, :msg_id)]
        ack = MTProto.Method.msgs_ack(msg_ids)
        Handler.send_encrypted(ack, session_id)
      "bad_server_salt" ->
        new_server_salt = Map.get(msg, :new_server_salt)
        Session.update session_id, server_salt: new_server_salt
      _ -> :noop
    end

    # Notify the client
    if session.client != nil do
      send session.client, {:tg, session_id, msg}
    else
      IO.puts "No client for #{session_id}, printing to console."
      IO.inspect {session_id, msg}
    end
  end

  ## Error Handling
  ## See https://core.telegram.org/api/errors

  # Handle errors for plain messages
  defp handle_error(session_id, msg) do
    error_code = Map.get(msg, :code)

    case error_code do
      -404 ->
        session = Session.get(session_id)
        if session.auth_key == <<0::8*8>> do
          Logger.debug "[MT][Brain] I received a -404 error. I still don't have an auth key
          for this DC (#{session.dc}) so I'm going to generate one ! I'm a workaround ;("
          Auth.req_pq(session_id)
        end
        _ -> Logger.warn "[MT][Brain] Unknown error : #{error_code}"
    end
  end

  # Handle errors for encrypted messages
  defp handle_rpc_error(_session_id, rpc_result) do
    error_code = Map.get(rpc_result, :error_code)
    error_message = Map.get(rpc_result, :error_message)

    Logger.warn "[MT][Brain] RPC error : #{error_code} | #{error_message}"
    case error_code do
      _ -> :noop
    end
  end
end
