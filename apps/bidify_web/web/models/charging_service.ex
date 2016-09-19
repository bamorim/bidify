defmodule Bidify.Web.ChargingService do
  @behaviour Bidify.Domain.ChargingService
  def reserve(_,_) do
    {:ok, :id}
  end

  def release(_), do: :ok

  def transfer(_,_,_), do: :ok
end
