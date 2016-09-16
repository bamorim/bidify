defmodule Bidify.Domain.AuctionTest do
  use ExUnit.Case
  alias Bidify.Domain.{Auction, Money}

  @bidder_id "bidder_id"
  @seller_id "seller_id"

  def auction do
    %Auction{minimum_bid: m(100), seller_id: @seller_id}
  end

  def m(a) do
    %Money{amount: a, currency: :brl}
  end

  test "we can place a bid" do
    assert {:ok, _} = auction |> Auction.place_bid(@bidder_id, m(100))
  end

  test "Cannot place bid smaller then the minimum bid" do
    assert {:error, _} = auction |> Auction.place_bid(@bidder_id, m(99))
  end

  test "Bidder cannot bid on a auction he is already winning"do
    {:ok, winning_auction} = auction |> Auction.place_bid(@bidder_id, m(101))
    assert {:error, _} = winning_auction |> Auction.place_bid(@bidder_id, m(102))
  end

  test "Cannot bid less than the current winning bid's amount" do
    {:ok, new_auction} = auction |> Auction.place_bid(@bidder_id, m(102))
    assert {:error, _} = new_auction |> Auction.place_bid("another_bidder_id", m(101))
  end

  test "Cannot bid same as the current winning bid's amount" do
    {:ok, new_auction} = auction |> Auction.place_bid(@bidder_id, m(102))
    assert {:error, _} = new_auction |> Auction.place_bid("another_bidder_id", m(102))
  end

  test "Cannot bid in his own auction" do
    assert {:error, _} = auction |> Auction.place_bid(@seller_id, m(101))
  end

  test "Cannot bid in a different cuurrency" do
    assert {:error, _} = auction |> Auction.place_bid(@bidder_id, %Money{amount: 101, currency: :usd})
  end
end
