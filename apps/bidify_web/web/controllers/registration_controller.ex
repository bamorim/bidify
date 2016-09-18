defmodule Bidify.Web.RegistrationController do
  use Bidify.Web.Web, :controller
  alias Bidify.Web.User

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    IO.puts inspect(user_params)
    IO.puts inspect(changeset)
    case Bidify.Web.Registration.create(changeset, Bidify.Web.Repo) do
      {:ok, user} ->
        conn
        |> Guardian.Plug.sign_in(user)
        |> redirect(to: "/")

      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
  end
end
