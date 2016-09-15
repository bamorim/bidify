defmodule Bidify.Domain.Auction do
  @moduledoc """
  Represents an auction, which is the aggregate root of the Auction aggregate.

  # Ubiquitous Language
  One can place a bid if:
  * He is not the owner of the auction
  * He is not the one currently winning the auction
  * The bid value is bigger than the current winning bid
  """

  alias Bidify.Domain.{Auction, Bid, Person}

  @type id :: integer
  @type t :: %Auction{id: id, minimum_bid: integer, seller_id: Person.id, bids: [Bid.t]}
  defstruct id: nil, minimum_bid: 0, seller_id: nil, bids: []

  @doc "Gives the minimum value for the next bid"
  @spec minimum_bid_amount(t) :: integer
  def minimum_bid_amount(auction) do
    case winning_bid(auction) do
      %Bid{amount: amount} ->
        amount
      _ ->
        auction.minimum_bid
    end
  end

  @doc "Gives the id of the current winner"
  @spec winning_bidder_id(t) :: Person.t | nil
  def winning_bidder_id(auction) do
    with %Bid{bidder_id: bidder_id} <- winning_bid(auction), do: bidder_id
  end

  @doc "Gives the currently winning bid"
  @spec winning_bid(t) :: Bid.t | nil
  def winning_bid(auction) do
    case auction.bids do
      [] ->
        nil
      bids ->
        bids |> Enum.max_by(&(&1.amount))
    end
  end

  @doc "Use Case: Place a bid"
  @spec place_bid(t, Person.id, integer) :: {:ok, t} | {:error, binary}
  def place_bid(auction, bidder_id, amount) do
    cond do
      minimum_bid_amount(auction) > amount ->
        {:error, "bid amount is not enough"}

      winning_bidder_id(auction) == bidder_id ->
        {:error, "cannot bid on auction when winning already"}

      auction.seller_id == bidder_id ->
        {:error, "cannot bid on own auction"}

      true ->
        {:ok, auction |> do_place_bid(bidder_id, amount)}
    end
  end

  @doc "Actually modify the auction to include the bid"
  @spec do_place_bid(t, Person.id, integer) :: t
  defp do_place_bid(auction, bidder_id, amount) do
    bid = %Bid{bidder_id: bidder_id, amount: amount}
    %{auction | bids: [bid | auction.bids]}
  end
end
