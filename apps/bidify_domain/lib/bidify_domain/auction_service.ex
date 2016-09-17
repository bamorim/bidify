defmodule Bidify.Domain.AuctionService do
  @moduledoc """
  Service to orchestrate the place bid usecase.
  """

  alias Bidify.Domain.{ChargingService, AuctionRepository, Auction, Money}

  defmodule Config do
    defstruct charging_service: nil, auction_repository: nil
  end
  @type config :: %Config{charging_service: ChargingService.t, auction_repository: AuctionRepository.t}
  @type person_id :: term

  @doc "UseCase: Create an auction"
  @spec create_auction(config, person_id, binary, Money.t) :: {:ok, Auction.t} | {:error, term}
  def create_auction(config, person_id, name, minimum_bid) do
    with %Auction{} = auction <- Auction.create(person_id, name, minimum_bid),
    do: config.auction_repository.create(auction)
  end

  @doc "Use Case: Place a bid"
  @spec place_bid(config, Auction.id, person_id, Money.t) :: {:ok, Auction.t} | {:error, term}
  def place_bid(config, auction_id, person_id, amount) do
    config.auction_repository.transaction(fn ->
      with \
        {:ok, r_id} <- config.charging_service.reserve(person_id, amount)
      do
        with \
          {:ok, auction} <- config.auction_repository.find(auction_id),
          :ok <- config.charging_service.release(Auction.winning_reservation_id(auction)),
          {:ok, new_auction} <- Auction.place_bid(auction, person_id, amount, r_id),
          :ok <- config.auction_repository.save(new_auction)
        do
          {:ok, new_auction}
        else
          err ->
            config.charging_service.release(r_id)
            config.auction_repository.rollback
        end
      end
    end)
  end
end
