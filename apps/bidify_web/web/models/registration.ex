defmodule Bidify.Web.Registration do
  import Ecto.Changeset, only: [put_change: 3]

  def create(changeset, repo) do
    changeset
    |> put_change(:encrypted_password, hashed_pw(changeset.params["password"]))
    |> repo.insert()
  end

  defp hashed_pw(pw) do
    Comeonin.Bcrypt.hashpwsalt(pw)
  end
end
