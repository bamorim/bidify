defmodule Bidify.Domain.AuctionService do
  @moduledoc """
  Service to orchestrate the place bid usecase.
  """

  alias Bidify.Domain.{ChargingService, AuctionRepository, Auction, Money, Bid}

  defmodule Config do
    defstruct charging_service: nil, auction_repository: nil
  end
  @type config :: %Config{charging_service: ChargingService.t, auction_repository: AuctionRepository.t}
  @type person_id :: term

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      [charging_service: charging_service, auction_repository: auction_repository] = opts
      @config %Config{charging_service: charging_service, auction_repository: auction_repository}
      @mod Bidify.Domain.AuctionService

      def create_auction(p_id, name, m_bid), do: @mod.create_auction(@config, p_id, name, m_bid)
      def close_auction(a_id), do: @mod.close_auction(@config, a_id)
      def place_bid(a_id, p_id, val), do: @mod.place_bid(@config, a_id, p_id, val)
    end
  end

  @doc "UseCase: Create an auction"
  @spec create_auction(config, person_id, binary, Money.t) :: {:ok, Auction.t} | {:error, term}
  def create_auction(config, person_id, name, minimum_bid) do
    with %Auction{} = auction <- Auction.create(person_id, name, minimum_bid),
    do: config.auction_repository.create(auction)
  end

  @doc "Use Case: Close auction"
  def close_auction(config, auction_id) do
    config.auction_repository.transaction(fn ->
      with \
        {:ok, auction} <- config.auction_repository.find(auction_id),
        {:ok, auction} <- Auction.close(auction),
        bid <- Auction.winning_bid(auction),
        :ok <- config.charging_service.release(bid.reservation_id),
        :ok <- config.charging_service.transfer(bid.bidder_id, bid.value, auction.seller_id)
      do
        {:ok, auction}
      end
    end)
  end

  @doc "Use Case: Place a bid"
  @spec place_bid(config, Auction.id, person_id, Money.t) :: {:ok, Auction.t} | {:error, term}
  def place_bid(config, auction_id, person_id, value) do
    config.auction_repository.transaction(fn ->
      with \
        {:ok, r_id} <- config.charging_service.reserve(person_id, value)
      do
        with \
          bid <- %Bid{value: value, reservation_id: r_id, bidder_id: person_id},
          {:ok, auction} <- config.auction_repository.find(auction_id),
          :ok <- config.charging_service.release(Auction.winning_reservation_id(auction)),
          {:ok, new_auction} <- Auction.place_bid(auction, bid),
          :ok <- config.auction_repository.save(new_auction)
        do
          {:ok, new_auction}
        else
          {:error, err} ->
            config.charging_service.release(r_id)
            config.auction_repository.rollback(err)
        end
      end
    end)
  end
end
