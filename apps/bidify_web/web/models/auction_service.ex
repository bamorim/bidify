defmodule Bidify.Web.AuctionService do
  use Bidify.Domain.AuctionService,
    charging_service: Bidify.Web.ChargingService,
    auction_repository: Bidify.Web.AuctionRepository
end
