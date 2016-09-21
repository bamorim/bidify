defmodule Bidify.Web.BidController do
  use Bidify.Web.Web, :controller

  def create(conn, %{"auction_id" => auction_id, "bid" => %{"amount" => amount}}) do
    {amount, _} = Integer.parse(amount)
    {auction_id, _} = Integer.parse(auction_id)
    value = %Bidify.Domain.Money{amount: amount}

    current_user = Bidify.Web.Session.current_user(conn)
    result = Bidify.Web.AuctionService.place_bid(auction_id, current_user.id, value)
    case result do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Thanks for the bid")
        |> redirect(to: auction_path(conn, :show, auction_id))
      {:error, err} ->
        conn
        |> put_flash(:error, "Error: #{inspect(err)}")
        |> redirect(to: auction_path(conn, :show, auction_id))
    end
  end
end
