defmodule Bidify.Domain.Auction do
  alias Bidify.Domain.{Auction, Bid, Person}

  @type t :: %Auction{minimum_bid: integer, seller_id: Person.id_t, bids: [Bid.t]}
  defstruct minimum_bid: 0, seller_id: nil, bids: []

  @spec minimum_bid_amount(t) :: integer
  def minimum_bid_amount(auction) do
    case winning_bid(auction) do
      %Bid{amount: amount} ->
        amount
      _ ->
        auction.minimum_bid
    end
  end

  @spec winning_bidder_id(t) :: Person.t | nil
  def winning_bidder_id(auction) do
    case winning_bid(auction) do
      %Bid{bidder_id: bidder_id} ->
        bidder_id
      _ ->
        nil
    end
  end

  @spec winning_bid(t) :: Bid.t | nil
  def winning_bid(auction) do
    case auction.bids do
      [] ->
        nil
      bids ->
        bids |> Enum.max_by(&(&1.amount))
    end
  end

  @spec place_bid(t, Person.id_t, integer) :: {:ok, t} | {:error, binary}
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

  @spec do_place_bid(t, Person.id_t, integer) :: t
  defp do_place_bid(auction, bidder_id, amount) do
    bid = %Bid{bidder_id: bidder_id, amount: amount}
    %{auction | bids: [bid | auction.bids]}
  end
end
