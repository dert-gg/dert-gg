defmodule DertGgWeb.PageController do
  use DertGgWeb, :controller

  def home(conn, _params) do
    conn =
      case conn.assigns.current_user do
        nil ->
          conn

        current_user ->
          # Generate a new JWT token for the current user
          # This means it'll always be generated whenever they navigate to the home page
          # But we go YOLO now, until we get it working
          assign(conn, :jwt, DertGg.Accounts.JwtToken.generate_and_sign!(%{user_id: current_user.id}))
      end

    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
