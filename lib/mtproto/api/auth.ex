defmodule MTProto.API.Auth do
  alias MTProto.TL.Build

  @moduledoc """
  Auth.*
  See [core.telegram.org/schema](https://core.telegram.org/schema).
  """

  def check_phone(phone) do
    Build.payload("auth.checkPhone", %{phone_number: phone})
  end

  def send_code(phone, sms_type \\ 0, lang \\ "en") do
    api_id = Application.get_env(:mtproto, :api_id)
    api_hash = Application.get_env(:mtproto, :api_hash)

    Build.payload("auth.sendCode",
                  %{phone_number: phone, sms_type: sms_type, api_id: api_id, api_hash: api_hash, lang_code: lang}
                )
  end

  def send_call(phone_number, phone_code_hash) do
    Build.payload("auth.sendCall", %{phone_number: phone_number, phone_code_hash: phone_code_hash})
  end

  def sign_up(phone_number, phone_code_hash, phone_code, first_name, last_name) do
    Build.payload("auth.signUp",
                  %{phone_number: phone_number,
                   phone_code_hash: phone_code_hash,
                   phone_code: phone_code,
                   first_name: first_name,
                   last_name: last_name})
  end

  def sign_in(phone_number, phone_code_hash, phone_code) do
    Build.payload("auth.signIn",
                  %{phone_number: phone_number,
                   phone_code_hash: phone_code_hash,
                   phone_code: phone_code})
  end

  def log_out do
    Build.payload("auth.logOut", %{})
  end

  def reset_authorizations do
    Build.payload("auth.resetAuthorizations", %{})
  end

  def send_invites(phone_numbers, message) do
    Build.payload("auth.sendInvites", %{phone_numbers: phone_numbers, message: message})
  end

  def export_authorization(dc_id) do
    Build.payload("auth.exportAuthorization", %{dc_id: dc_id})
  end

  def import_authorization(user_id, auth_key) do
    Build.payload("auth.importAuthorization", %{id: user_id, bytes: auth_key})
  end

  def bind_tmp_auth_key(perm_auth_key_id, nonce, expires_at, encrypted_message) do
    Build.payload("auth.bindTempAuthKey",
                  %{perm_auth_key_id: perm_auth_key_id,
                   nonce: nonce,
                   expires_at: expires_at,
                   encrypted_message: encrypted_message})
  end

  def send_sms(phone_number, phone_code_hash) do
    Build.payload("auth.sendSms", %{phone_number: phone_number, phone_code_hash: phone_code_hash})
  end
end
