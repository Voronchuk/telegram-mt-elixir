defmodule MTProto.DC do
  alias MTProto.{Registry, DC}

  @moduledoc """
  Define a datacenter. Note that all the possible values (indexed in the
  registry) are hardcoded in `MTProto.DC.register/0`.

  * `:id` - id  of the dc
  * `:address` - address of the dc
  * `:port` - port of the dc, default to `443`
  * `:auth_key` - authorization key, default to `<<0::8*8>>`
  * `server_salt` - default to `0`
  """

  defstruct id: nil,
            address: nil,
            port: 443,
            auth_key: <<0::8*8>>,
            server_salt: 0

  @doc """
  Register all five DCs in the registry. Values are hardcoded.
  """
  def register do
    Registry.set :dc, 1, %DC{id: 1, address: "149.154.175.50"}
    Registry.set :dc, 2, %DC{id: 2, address: "149.154.167.51"}
    Registry.set :dc, 3, %DC{id: 3, address: "149.154.175.100"}
    Registry.set :dc, 4, %DC{id: 4, address: "149.154.167.91"}
    Registry.set :dc, 5, %DC{id: 5, address: "149.154.171.5"}
  end

  @doc """
  Export the authorization key for DC `dc_id`.
  """
  def export_authorization_key(dc_id) do
    dc = Registry.get :dc, dc_id
    dc.auth_key
  end

  @doc """
  Import `auth_key` as the authorization key for DC `dc_id`.
  """
  def import_authorization_key(dc_id, auth_key) do
    Registry.set :dc, dc_id, :auth_key, auth_key
  end
end
