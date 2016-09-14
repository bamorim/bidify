defmodule Bidify.Domain.Auction do
  alias Bidify.Domain.{Auction, Bid}
  defstruct minimum_bid: 0, bids: []

  def minimum_bid_amount(auction) do
    case winning_bid(auction) do
      %Bid{amount: amount} ->
        amount
      _ ->
        auction.minimum_bid
    end
  end

  def winning_bidder_id(auction) do
    case winning_bid(auction) do
      %Bid{bidder_id: bidder_id} ->
        bidder_id
      _ ->
        nil
    end
  end

  def winning_bid(auction) do
    case auction.bids do
      [] ->
        nil
      bids ->
        bids |> Enum.max_by(&(&1.amount))
    end
  end

  def place_bid(auction, bidder_id, amount) do
    cond do
      minimum_bid_amount(auction) > amount ->
        {:error, "bid amount is not enough"}

      winning_bidder_id(auction) == bidder_id ->
        {:error, "cannot bid on auction when winning already"}

      true ->
        {:ok, auction |> do_place_bid(bidder_id, amount)}
    end
  end

  defp do_place_bid(auction, bidder_id, amount) do
    bid = %Bid{bidder_id: bidder_id, amount: amount}
    %Auction{auction | bids: [bid | auction.bids]}
  end
end
