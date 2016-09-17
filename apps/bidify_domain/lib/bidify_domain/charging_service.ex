defmodule Bidify.Domain.ChargingService do
  @moduledoc """
  Specification for a Charging Service
  """

  alias Bidify.Domain.Money

  @type t :: module
  @type reservation_id :: term
  @type person_id :: term

  @doc """
  Reserves an amount of money for use later
  """
  @callback reserve(person_id, Money.t) :: {:ok, reservation_id} | {:error, term}

  @doc """
  Relases a reservation
  """
  @callback release(reservation_id) :: :ok | {:error, term}

  @doc """
  Transfer money from one person to another
  """
  @callback transfer(person_id, Money.t, person_id) :: :ok | {:error, term}
end
