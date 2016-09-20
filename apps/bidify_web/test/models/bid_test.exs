defmodule Bidify.Web.BidTest do
  use Bidify.Web.ModelCase

  alias Bidify.Web.Bid

  @valid_attrs %{value_amount: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Bid.changeset(%Bid{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Bid.changeset(%Bid{}, @invalid_attrs)
    refute changeset.valid?
  end
end
