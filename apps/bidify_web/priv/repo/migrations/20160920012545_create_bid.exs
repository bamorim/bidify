defmodule Bidify.Web.Repo.Migrations.CreateBid do
  use Ecto.Migration

  def change do
    create table(:bids) do
      add :value_amount, :integer
      add :bidder_id, references(:users, on_delete: :nothing)
      add :auction_id, references(:auctions, on_delete: :nothing)

      timestamps()
    end
    create index(:bids, [:bidder_id])
    create index(:bids, [:auction_id])
  end
end
