defmodule DertGg.Repo do
  use Ecto.Repo,
    otp_app: :dert_gg,
    adapter: Ecto.Adapters.Postgres
end
