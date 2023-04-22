defmodule DertGg.Accounts.JwtToken  do
  use Joken.Config

  @impl true
  def token_config do
    default_claims(
      default_exp: 60 * 60 * 24 * 7, # 1 week
      skip: [:aud, :nbf, :iss]
    )
  end
end
