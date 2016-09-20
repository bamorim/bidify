defmodule Bidify.Web.Bid do
  use Bidify.Web.Web, :model

  schema "bids" do
    field :value_amount, :integer
    belongs_to :bidder, Bidify.Web.User
    belongs_to :auction, Bidify.Web.Auction

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:bidder_id])
    |> put_change(:value_amount, params[:value][:amount])
    |> validate_required([:value_amount, :bidder_id])
  end
end
