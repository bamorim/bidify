defmodule Bidify.Web.Session do
  alias Bidify.Web.User

  def current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end

  def logged_in?(conn), do: !!current_user(conn)

  def login(params, repo) do
    user = repo.get_by(User, email: String.downcase(params["email"]))
    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.encrypted_password)
    end
  end
end
