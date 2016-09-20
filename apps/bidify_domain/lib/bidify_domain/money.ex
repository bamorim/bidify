defmodule Bidify.Domain.Money do
  @moduledoc """
  Value object for holding monetary value
  """

  alias Bidify.Domain.Money

  defstruct amount: 0, currency: :brl
  @type currency :: :usd | :brl | :gbp | :eur
  @type t :: %Money{amount: integer, currency: currency}

  @spec new(integer, currency) :: t
  def new(amount \\ 0, currency \\ :brl) do
    %Money{amount: amount, currency: currency}
  end

  @spec add(t | integer, t | integer) :: t
  def add(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}) do
    %Money{amount: a1+a2, currency: c}
  end
  def add(%Money{amount: a, currency: c}, v) when is_number(v) do
    %Money{amount: a+v, currency: c}
  end
  def add(v, m = %Money{}) when is_number(v) do
    add(m,v)
  end

  @spec sub(t | integer, t | integer) :: t
  def sub(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}) do
    %Money{amount: a1-a2, currency: c}
  end
  def sub(%Money{amount: a, currency: c}, v) when is_number(v) do
    %Money{amount: a-v, currency: c}
  end
  def sub(v, %Money{amount: a, currency: c}) when is_number(v) do
    %Money{amount: v-a, currency: c}
  end
end

defimpl Bidify.Utils.Comparable, for: Bidify.Domain.Money do
  alias Bidify.Domain.Money
  def compare(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}) do
    Bidify.Utils.Comparable.compare(a1, a2)
  end
end
