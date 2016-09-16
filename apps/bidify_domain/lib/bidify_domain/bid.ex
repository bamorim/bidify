defmodule Bidify.Domain.Bid do
  alias Bidify.Domain.{Bid, Person, Money}

  @type t :: %Bid{bidder_id: Person.t, value: Money.t}
  defstruct bidder_id: nil, value: nil
end
