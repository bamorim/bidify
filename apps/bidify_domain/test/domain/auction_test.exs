defmodule Bidify.Domain.AuctionTest do
  use ExUnit.Case
  alias Bidify.Domain.{Auction, Money}

  @bidder_id "bidder_id"
  @seller_id "seller_id"

  def auction do
    %Auction{minimum_bid: m(100), seller_id: @seller_id}
  end

  def m(a, currency \\ :brl) do
    %Money{amount: a, currency: currency}
  end

  test "we can place a bid" do
    assert {:ok, _} = auction |> Auction.place_bid(@bidder_id, m(100), :rid)
  end

  test "Cannot place bid smaller then the minimum bid" do
    assert {:error, _} = auction |> Auction.place_bid(@bidder_id, m(99), :rid)
  end

  test "Bidder cannot bid on a auction he is already winning"do
    {:ok, winning_auction} = auction |> Auction.place_bid(@bidder_id, m(101), :rid)
    assert {:error, _} = winning_auction |> Auction.place_bid(@bidder_id, m(102), :rid)
  end

  test "Cannot bid less than the current winning bid's amount" do
    {:ok, new_auction} = auction |> Auction.place_bid(@bidder_id, m(102), :rid)
    assert {:error, _} = new_auction |> Auction.place_bid("another_bidder_id", m(101), :rid)
  end

  test "Cannot bid same as the current winning bid's amount" do
    {:ok, new_auction} = auction |> Auction.place_bid(@bidder_id, m(102), :rid)
    assert {:error, _} = new_auction |> Auction.place_bid("another_bidder_id", m(102), :rid)
  end

  test "Cannot bid in his own auction" do
    assert {:error, _} = auction |> Auction.place_bid(@seller_id, m(101), :rid)
  end

  test "Cannot bid in a different cuurrency" do
    assert {:error, _} = auction |> Auction.place_bid(@bidder_id, m(101,:usd), :rid)
  end

  test "Can create an auction" do
    assert %Auction{} = Auction.create(:seller_id, "name", m(1))
  end

  test "Auction is valdiated" do
    assert {:error, _} = Auction.create(:seller_id, "name", 1), "Starting bid should be a Money"
    assert {:error, _} = Auction.create(nil, "name", m(1)), "Seller id is required"
    assert {:error, _} = Auction.create(:seller_id, nil, m(1)), "Name is required"
  end

  test "The system can close an auction" do
    {:ok, auction} = Auction.close(auction)
    assert auction.closed == true
  end

  test "Cannot close an auction that is already closed" do
    {:ok, auction} = Auction.close(auction)
    assert {:error, _} = Auction.close(auction)
  end

  test "Cannot place a bid in a closed auction" do
    {:ok, auction} = Auction.close(auction)

    assert {:error, _} = auction
    |> Auction.place_bid(@bidder_id, m(100), :rid)
  end
end
