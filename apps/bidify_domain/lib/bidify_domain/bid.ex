defmodule Bidify.Domain.Bid do
  alias Bidify.Domain.{Bid, Money}

  @type person_id :: term
  @type t :: %Bid{bidder_id: person_id, value: Money.t, reservation_id: term}
  defstruct bidder_id: nil, value: nil, reservation_id: nil
end
