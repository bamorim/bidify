defmodule Bidify.Web.AuctionRepository do
  @behaviour Bidify.Domain.AuctionRepository
  import Ecto.Query, only: [from: 2]

  def find(id) do
    with {:ok, auction} <- web_find(id), do: {:ok, to_domain(auction)}
  end

  defp web_find(id) do
    case Bidify.Web.Repo.get(Bidify.Web.Auction, id) |> Bidify.Web.Repo.preload([:bids]) do
      nil -> {:error, "Auction not found"}
      auction -> {:ok, auction}
    end
  end

  def save(auction) do
    with \
      {:ok, web_auction} <- web_find(auction.id),
      {_n, _elms} <- from(b in Bidify.Web.Bid, where: b.auction_id == ^web_auction.id) |> Bidify.Web.Repo.delete_all,
      {:ok, _} <- Bidify.Web.Repo.update(web_auction |> domain_changeset(auction)),
      bids_params <- auction.bids |> Enum.map(&bid_to_params(auction, &1)),
      {_n, _elms} <- Bidify.Web.Repo.insert_all(Bidify.Web.Bid, bids_params),
      do: :ok
  end

  def create(auction) do
    web_auction = %Bidify.Web.Auction{} |> domain_changeset(auction)

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

  defp bid_to_params(auction, bid) do
    {:ok, current_time} = Ecto.DateTime.cast(:erlang.timestamp |> :calendar.now_to_datetime)
    %{value_amount: bid.value.amount, bidder_id: bid.bidder_id, auction_id: auction.id, inserted_at: current_time, updated_at: current_time}
  end

  defp domain_changeset(struct, auction) do
    Bidify.Web.Auction.changeset(struct, struct_to_map(auction))
  end

  defp struct_to_map([h|t]), do: [struct_to_map(h)|struct_to_map(t)]
  defp struct_to_map(%{__struct__: _} = struct) do
    struct |> Map.to_list |> Keyword.delete(:__struct__) |> Enum.map(fn {k,v} -> {k,struct_to_map(v)} end) |> Enum.into(%{})
  end
  defp struct_to_map(any), do: any

  defp to_domain(%Bidify.Web.Bid{} = bid) do
    %Bidify.Domain.Bid{
      value: %Bidify.Domain.Money{amount: bid.value_amount},
      bidder_id: bid.bidder_id
    }
  end
  defp to_domain(%Bidify.Web.Auction{} = auction) do
    %Bidify.Domain.Auction{
      id: auction.id,
      minimum_bid: %Bidify.Domain.Money{amount: auction.minimum_bid_amount},
      name: auction.name,
      bids: case auction.bids do
        %Ecto.Association.NotLoaded{} -> []
        bids -> bids |> Enum.map(&to_domain(&1))
      end,
      closed: auction.closed,
      seller_id: auction.seller_id
    }
  end
end
