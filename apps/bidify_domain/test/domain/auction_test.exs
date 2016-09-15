defmodule Bidify.Domain.AuctionTest do
  use ExUnit.Case
  alias Bidify.Domain.Auction

  @bidder_id "bidder_id"
  @seller_id "seller_id"

  def auction do
    %Auction{minimum_bid: 10, seller_id: @seller_id}
  end

  test "we can place a bid" do
    assert {:ok, _} = auction |> Auction.place_bid(@bidder_id, 11)
  end

  test "Cannot place bid smaller then the minimum bid" do
    assert {:error, _} = auction |> Auction.place_bid(@bidder_id, 9)
  end

  test "Bidder cannot bid on a auction he is already winning"do
    {:ok, winning_auction} = auction |> Auction.place_bid(@bidder_id, 11)
    assert {:error, _} = winning_auction |> Auction.place_bid(@bidder_id, 12)
  end

  test "Cannot bid less than the current winning bid's ammount" do
    {:ok, new_auction} = auction |> Auction.place_bid(@bidder_id, 12)
    assert {:error, _} = new_auction |> Auction.place_bid("another_bidder_id", 11)
  end

  test "Cannot bid in his own auction" do
    assert {:error, _} = auction |> Auction.place_bid(@seller_id, 11)
  end
end
