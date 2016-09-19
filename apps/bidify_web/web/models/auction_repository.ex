defmodule Bidify.Web.AuctionRepository do
  @behaviour Bidify.Domain.AuctionRepository

  def find(id) do
    Bidify.Web.Repo.get(Bidify.Web.Auction, id)
  end

  def save(auction) do
    with \
      {:ok, web_auction} <- Bidify.Web.Repo.get(auction.id),
      web_auction <- web_auction |> Bidify.Web.Auction.domain_chageset(auction),
      {:ok, _} <- Bidify.Web.Repo.update(web_auction),
      do: :ok
  end

  def create(auction) do
    web_auction = %Bidify.Web.Auction{}
    |> Bidify.Web.Auction.domain_changeset(auction)

    IO.puts(inspect(web_auction))
    IO.puts(inspect(auction))

    case Bidify.Web.Repo.insert(web_auction) do
      {:ok, _} -> {:ok, auction}
      err -> err
    end
  end

  def transaction(fun) do
    Bidify.Web.Repo.transaction(fun)
  end

  def rollback() do
    Bidify.Web.Repo.rollback
  end
end
