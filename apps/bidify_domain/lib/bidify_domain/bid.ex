defmodule Bidify.Domain.Bid do
  alias Bidify.Domain.{Bid, Person, Money}

  @type t :: %Bid{bidder_id: Person.t, value: Money.t, reservation_id: term}
  defstruct bidder_id: nil, value: nil, reservation_id: nil
end
