defmodule Bidify.Web.AuctionTest do
  use Bidify.Web.ModelCase

  alias Bidify.Web.Auction

  @valid_attrs %{closed: true, minimum_bid_amount: "some content", name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Auction.changeset(%Auction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Auction.changeset(%Auction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
