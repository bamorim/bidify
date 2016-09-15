defmodule Bidify.Domain.Bid do
  alias Bidify.Domain.{Bid, Person}

  @type t :: %Bid{bidder_id: Person.t, amount: integer}
  defstruct bidder_id: nil, amount: 0
end
