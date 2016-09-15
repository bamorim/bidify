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

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def find(id) do
    {:ok, Agent.get(__MODULE__, &(Map.get(&1, id)))}
  end

  def save(auction) do
    Agent.update(__MODULE__, &(Map.put(&1, auction.id, auction)))
    :ok
  end

  def create(auction) do
    Agent.get_and_update(__MODULE__, fn map ->
      id = case map |> Map.keys do
             [] -> 1
             ids -> Enum.max(ids) + 1
           end
      auction = %{auction | id: id}
      {auction, Map.put(map, auction.id, auction)}
    end)
  end
end

defmodule Bidify.Domain.BiddingServiceTest do
  alias Bidify.DomainTest.{InMemoryAuctionRepository, AcceptingChargingService, BiddingService}
  alias Bidify.Domain.{Auction, BiddingService}

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

  test "We can place an auction", context do
    bidder_id = :bidder
    auction = InMemoryAuctionRepository.create(%Auction{id: 1, minimum_bid: 10, seller_id: :seller})

    result = context[:config]
    |> BiddingService.place_bid(auction.id, bidder_id, 11)

    assert result == :ok

    {:ok, modified_auction} = InMemoryAuctionRepository.find(auction.id)

    assert Enum.count(modified_auction.bids) == 1
  end
end
