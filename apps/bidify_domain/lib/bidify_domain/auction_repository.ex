defmodule Bidify.Domain.AuctionRepository do
  @defmodule """
  Defines the behaviour for a auction repository
  """

  @type t :: __MODULE__

  alias Bidify.Domain.Auction

  @doc """
  Gets an auction by it's identification
  """
  @callback find(Auction.id) :: {:ok, Auction.t} | {:error, term}

  @doc """
  Persists an auction by it's identification
  """
  @callback save(Auction.t) :: :ok | {:error, term}

  @doc """
  Persists an auction and assign an ID
  """
  @callback create(Auction.t) :: {:ok, Auction.t} | {:error, term}

  @doc """
  Start a transaction
  """
  @callback transaction((... -> any)) :: :ok | {:error, term}

  @doc """
  Rollback the current transaction
  """
  @callback rollback :: :ok
end
