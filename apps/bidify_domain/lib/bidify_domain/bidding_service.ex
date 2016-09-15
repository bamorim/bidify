defmodule Bidify.Domain.BiddingService do
  @moduledoc """
  Service to orchestrate the place bid usecase.
  """

  alias Bidify.Domain.{ChargingService, AuctionRepository, Auction, Person}

  defmodule Config do
    defstruct charging_service: nil, auction_repository: nil
  end
  @type config :: %Config{charging_service: ChargingService.t, auction_repository: AuctionRepository.t}

  @spec place_bid(config, Auction.id, Person.id, integer) :: {:ok, Auction.t} | {:error, term}
  def place_bid(config, auction_id, person_id, amount) do
    with {:ok, _reservation_id} <- config.charging_service.reserve(person_id, amount),
         {:ok, auction} <- config.auction_repository.find(auction_id),
         {:ok, new_auction} <- Auction.place_bid(auction, person_id, amount),
      do: config.auction_repository.save(new_auction)
  end
end
