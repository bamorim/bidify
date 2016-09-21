defmodule Bidify.Web.AuctionController do
  use Bidify.Web.Web, :controller

  def index(conn, _params) do
    auctions = Bidify.Web.Repo.all Bidify.Web.Auction
    render conn, "index.html", auctions: auctions
  end

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"auction" => auction_params}) do
    {minimum_bid_amount, _} = auction_params["minimum_bid_amount"] |> Integer.parse
    minimum_bid = Bidify.Domain.Money.new(minimum_bid_amount)
    name = auction_params["name"]
    current_user = Bidify.Web.Session.current_user(conn)
    case Bidify.Web.AuctionService.create_auction(current_user.id, name, minimum_bid) do
      {:ok, auction} ->
        conn
        |> put_flash(:info, "Auction placed")
        |> redirect(to: "/")
      {:error, err} ->
        conn
        |> put_flash(:error, "Error #{err}")
        |> render("new.html")
    end
  end

  def show(conn, %{"id" => auction_id}) do
    {auction_id, _} = Integer.parse(auction_id)
    {:ok, auction} = Bidify.Web.AuctionRepository.find(auction_id)
    winning_bid = Bidify.Domain.Auction.winning_bid(auction)
    IO.puts(inspect(auction))
    render conn, "show.html", auction: auction, winning_bid: winning_bid
  end
end
