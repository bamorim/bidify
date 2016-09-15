defmodule Bidify.Domain.AuctionRepository do
  @defmodule """
  Defines the behaviour for a auction repository
  """

  alias Bidify.Domain.Auction

  @doc """
  Gets an auction by it's identification
  """
  @callback find(Auction.id) :: {:ok, Auction.t}

  @doc """
  Persists an auction by it's identification
  """
  @callback save(Auction.t) :: {:ok, Auction.id}
end
