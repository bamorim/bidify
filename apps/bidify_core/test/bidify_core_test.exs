defmodule Bidify.CoreTest do
  use ExUnit.Case
  doctest Bidify.Core

  alias Bidify.Core.Auction

  def auction do
    %Auction{minimum_bid: 10}
  end

  test "we can place a bid" do
    assert {:ok, _} = auction |> Auction.place_bid("id1", 11)
  end

  test "Cannot place bid smaller then the minimum bid" do
    assert {:error, _} = auction |> Auction.place_bid("id1", 9)
  end

  test "Bidder cannot bid on a auction he is already winning"do
    {:ok, winning_auction} = auction |> Auction.place_bid("id1", 11)
    assert {:error, _} = winning_auction |> Auction.place_bid("id1", 12)
  end

  test "Cannot bid less than the current winning bid's ammount" do
    {:ok, new_auction} = auction |> Auction.place_bid("id1", 12)
    assert {:error, _} = new_auction |> Auction.place_bid("id2", 11)
  end
end
