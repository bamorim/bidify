defmodule InMemoryChargingService do
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
