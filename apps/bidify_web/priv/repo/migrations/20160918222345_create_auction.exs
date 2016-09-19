defmodule Bidify.Web.Repo.Migrations.CreateAuction do
  use Ecto.Migration

  def change do
    create table(:auctions) do
      add :name, :string
      add :closed, :boolean, default: false, null: false
      add :minimum_bid_amount, :integer
      add :seller_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:auctions, [:seller_id])

  end
end
