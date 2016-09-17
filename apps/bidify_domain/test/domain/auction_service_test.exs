defmodule Bidify.DomainTest.InMemoryChargingService do
  @behaviour Bidify.Domain.ChargingService
  alias Bidify.Domain.Money
  defmodule Account do
    defstruct funds: %Money{}, reservations: %{}
  end

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def add_funds(id, value) do
    acc_transaction(id, fn acc ->
      acc = %{acc | funds: Money.add(acc.funds, value)}
      {:ok, acc}
    end)
  end

  def get(id) do
    Agent.get(__MODULE__, &(Map.get(&1, id)))
  end

  def reserve(id, value) do
    acc_transaction(id, fn acc ->
      funds = Money.sub(acc.funds, value)
      rid = next_reservation_id(acc)

      reservations = acc.reservations
      |> Map.put(rid, value)

      if funds.amount < 0 do
        {{:error, "insuficient funds"}, acc}
      else
        {{:ok,{id,rid}}, %Account{funds: funds, reservations: reservations}}
      end
    end)
  end

  def release({id, rid}) do
    acc_transaction(id, fn acc ->
      amount = acc.reservations |> Map.get(rid)
      reservations = acc.reservations |> Map.delete(rid)
      {:ok, %{acc | funds: acc.funds |> Money.add(amount), reservations: reservations}}
    end)
  end
  def release(nil), do: :ok

  def transfer(from, value, to) do
    acc_transaction(from, fn acc ->
      {:ok, %Account{acc | funds: acc.funds |> Money.sub(value)}}
    end)
    acc_transaction(to, fn acc ->
      {:ok, %Account{acc | funds: acc.funds |> Money.add(value)}}
    end)
  end

  defp next_reservation_id(%Account{reservations: %{}}), do: 1
  defp next_reservation_id(%Account{reservations: r}) do
    (r |> Map.keys |> Enum.max) + 1
  end

  def acc_transaction(id, fun) do
    Agent.get_and_update(__MODULE__, fn accounts ->
      acc = accounts |> Map.get(id) || %Account{}
      {resp, acc} = fun.(acc)
      accounts = accounts |> Map.put(id, acc)
      {resp, accounts}
    end)
  end

  def clear! do
    Agent.update(__MODULE__, fn _ -> %{} end)
  end
end

defmodule Bidify.DomainTest.InMemoryAuctionRepository do
  @behaviour Bidify.Domain.AuctionRepository
  use Bidify.Utils.InMemoryEntityRepository
end

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

  def create_auction do
    InMemoryAuctionRepository.create(%Auction{minimum_bid: m(10), seller_id: :seller})
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
end
