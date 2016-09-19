defmodule Bidify.Web.Auction do
  use Bidify.Web.Web, :model

  schema "auctions" do
    field :name, :string
    field :closed, :boolean, default: false
    field :minimum_bid_amount, :integer
    belongs_to :seller, Bidify.Web.Seller

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :closed, :minimum_bid_amount])
    |> validate_required([:name, :closed, :minimum_bid_amount])
  end

  def domain_changeset(struct, auction) do
    struct
    |> cast(%{}, [])
    |> put_change(:name, auction.name)
    |> put_change(:closed, auction.closed)
    |> put_change(:minimum_bid_amount, auction.minimum_bid.amount)
  end
end
