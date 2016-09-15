defmodule Bidify.Domain.ChargingService do
  @moduledoc """
  Specification for a Charging Service
  """

  alias Bidify.Domain.Person

  @type t :: module
  @type money :: integer
  @type reservation_id :: integer

  @doc """
  Reserves an amount of money for use later
  """
  @callback reserve(Person.id, money) :: {:ok, reservation_id} | {:error, term}

  @doc """
  Relases a reservation
  """
  @callback release(reservation_id) :: :ok | {:error, term}

  @doc """
  Transfer money from one person to another
  """
  @callback transfer(Person.id, reservation_id | money, Person.id) :: :ok | {:error, term}
end
