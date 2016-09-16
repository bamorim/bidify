defmodule Bidify.DomainTest.DenyingChargingService do
  @behaviour Bidify.Domain.ChargingService

  def reserve(_pid, _amt), do: {:error, "unsuficient funds"}
  def release(_rid), do: :ok
  def transfer(_pid1, _rid, _pid2), do: {:error, "unsuficient funds"}
end

defmodule Bidify.DomainTest.AcceptingChargingService do
  @behaviour Bidify.Domain.ChargingService

  def reserve(_pid, _amt), do: {:ok, 1}
  def release(_rid), do: :ok
  def transfer(_pid1, _rid, _pid2), do: :ok
end

defmodule Bidify.DomainTest.InMemoryAuctionRepository do
  @behaviour Bidify.Domain.AuctionRepository
  use Bidify.Shared.InMemoryEntityRepository
end

defmodule Bidify.Domain.BiddingServiceTest do
  use ExUnit.Case
  alias Bidify.DomainTest.{InMemoryAuctionRepository, AcceptingChargingService, BiddingService}
  alias Bidify.Domain.{Auction, BiddingService, Money}

  setup_all do
    InMemoryAuctionRepository.start_link
    :ok
  end

  setup do
    config = %BiddingService.Config{
      auction_repository: InMemoryAuctionRepository,
      charging_service: AcceptingChargingService
    }
    [config: config]
  end

  def m(a) do
    %Money{amount: a, currency: :brl}
  end

  test "We can place an auction", context do
    bidder_id = :bidder
    {:ok, auction} = InMemoryAuctionRepository.create(%Auction{id: 1, minimum_bid: m(10), seller_id: :seller})

    result = context[:config]
    |> BiddingService.place_bid(auction.id, bidder_id, m(11))

    assert result == :ok

    {:ok, modified_auction} = InMemoryAuctionRepository.find(auction.id)

    assert Enum.count(modified_auction.bids) == 1
  end
end
