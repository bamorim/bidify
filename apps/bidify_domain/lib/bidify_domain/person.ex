defmodule Bidify.Domain.Person do
  @moduledoc "Someone who can bid and create auctions"
  alias Bidify.Domain.Person

  @type id :: integer
  @type t :: %Person{id: id}
  defstruct id: nil
end
