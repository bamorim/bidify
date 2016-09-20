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
    |> cast(params, [:name, :closed, :seller_id])
    |> put_change(:minimum_bid_amount, params[:minimum_bid][:amount])
    |> validate_required([:name, :closed, :seller_id, :minimum_bid_amount])
  end
end
