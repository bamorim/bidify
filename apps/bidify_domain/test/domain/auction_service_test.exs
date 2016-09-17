defmodule Bidify.Domain.AuctionServiceTest do
  use ExUnit.Case
  alias Bidify.DomainTest.{InMemoryAuctionRepository, InMemoryChargingService, AuctionService}
  alias Bidify.Domain.{Auction, AuctionService, Money}

  setup_all do
    InMemoryAuctionRepository.start_link
    InMemoryChargingService.start_link
    :ok
  end

  setup do
    InMemoryChargingService.clear!
    config = %AuctionService.Config{
      auction_repository: InMemoryAuctionRepository,
      charging_service: InMemoryChargingService
    }
    [config: config]
  end

  def m(a) do
    %Money{amount: a, currency: :brl}
  end

  def create_auction(seller \\ :seller) do
    InMemoryAuctionRepository.create(%Auction{minimum_bid: m(10), seller_id: seller})
  end

  test "Can place a bid", context do
    {:ok, auction} = create_auction

    InMemoryChargingService.add_funds :bidder, m(12)

    assert {:ok, _} = context[:config]
    |> AuctionService.place_bid(auction.id, :bidder, m(11))

    {:ok, modified_auction} = InMemoryAuctionRepository.find(auction.id)
    acc = InMemoryChargingService.get(:bidder)
    assert acc.funds == m(1)
    assert Enum.count(acc.reservations) == 1

    assert Enum.count(modified_auction.bids) == 1
  end

  test "Cannot place bid in an auction when user does not have enough funds", context do
    {:ok, auction} = create_auction

    InMemoryChargingService.add_funds :bidder, m(10)

    result = context[:config]
    |> AuctionService.place_bid(auction.id, :bidder, m(11))

    assert {:error, _} = result

    {:ok, modified_auction} = InMemoryAuctionRepository.find(auction.id)

    assert Enum.count(modified_auction.bids) == 0
  end

  test "Funds are released when someone is overbidded", context do
    {:ok, auction} = create_auction

    InMemoryChargingService.add_funds :bidder_1, m(11)
    InMemoryChargingService.add_funds :bidder_2, m(12)

    context[:config] |> AuctionService.place_bid(auction.id, :bidder_1, m(11))
    context[:config] |> AuctionService.place_bid(auction.id, :bidder_2, m(12))

    acc = InMemoryChargingService.get(:bidder_1)
    assert acc.funds == m(11)
    assert acc.reservations == %{}
  end

  test "Funds are not reserved if the bid fails", context do
    {:ok, auction} = create_auction

    InMemoryChargingService.add_funds :bidder, m(100)

    context[:config]
    |> AuctionService.place_bid(auction.id, :bidder, m(9))

    acc = InMemoryChargingService.get(:bidder)
    assert acc.reservations == %{}
    assert acc.funds == m(100)
  end

  test "One can create an auction", context do
    assert {:ok, auction} = context[:config]
    |> AuctionService.create_auction(:seller_id, "My Auction", m(10))

    assert auction.id != nil

    assert InMemoryAuctionRepository.find(auction.id) == {:ok, auction}
  end

  test "The system can close an auction", context do
    {:ok, auction} = create_auction(:seller)

    InMemoryChargingService.add_funds :bidder, m(10)

    context[:config]
    |> AuctionService.place_bid(auction.id, :bidder, m(10))

    assert {:ok, _} = context[:config]
    |> AuctionService.close_auction(auction.id)

    bidder_acc = InMemoryChargingService.get(:bidder)
  end
end
