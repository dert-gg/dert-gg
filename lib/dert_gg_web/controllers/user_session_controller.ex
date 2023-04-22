defmodule DertGgWeb.UserSessionController do
  use DertGgWeb, :controller

  alias DertGg.Accounts
  alias DertGgWeb.UserAuth

  def new(conn, _params) do
    render(conn, :new, error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Hoşgeldin kırmızı şortli")
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :new, error_message: "Yanlış email veya şifre")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Güle güle kırmızı şortli")
    |> UserAuth.log_out_user()
  end
end
