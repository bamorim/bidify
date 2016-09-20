defmodule Bidify.Web.AuctionRepository do
  @behaviour Bidify.Domain.AuctionRepository

  def find(id) do
    with {:ok, auction} <- web_find(id), do: {:ok, to_domain(auction)}
  end

  def web_find(id) do
    case Bidify.Web.Repo.get(Bidify.Web.Auction, id) do
      nil -> {:error, "Auction not found"}
      auction -> {:ok, auction}
    end
  end

  def save(auction) do
    with \
      {:ok, web_auction} <- web_find(auction.id),
      web_auction <- web_auction |> Bidify.Web.Auction.domain_changeset(auction),
      {:ok, _} <- Bidify.Web.Repo.update(web_auction),
      do: :ok
  end

  def create(auction) do
    web_auction = %Bidify.Web.Auction{}
    |> Bidify.Web.Auction.domain_changeset(auction)

    case Bidify.Web.Repo.insert(web_auction) do
      {:ok, _} -> {:ok, auction}
      err -> err
    end
  end

  def transaction(fun) do
    Bidify.Web.Repo.transaction(fun)
  end

  def rollback(error \\ "error ocurred") do
    Bidify.Web.Repo.rollback(error)
  end

  def to_domain(%Bidify.Web.Auction{} = auction) do
    %Bidify.Domain.Auction{
      id: auction.id,
      minimum_bid: %Bidify.Domain.Money{amount: auction.minimum_bid_amount},
      name: auction.name,
      bids: [],
      closed: auction.closed,
      seller_id: auction.seller_id
    }
  end
end
