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

  @spec plus(t,t) :: t
  def plus(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}) do
    %Money{amount: a1+a2, currency: c}
  end
end

defimpl Bidify.Shared.Comparable, for: Bidify.Domain.Money do
  alias Bidify.Domain.Money
  def compare(%Money{amount: a1, currency: c}, %Money{amount: a2, currency: c}) do
    Bidify.Shared.Comparable.compare(a1, a2)
  end
end
