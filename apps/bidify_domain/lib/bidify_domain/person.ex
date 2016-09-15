defmodule Bidify.Domain.Person do
  @moduledoc "Someone who can bid and create auctions"
  alias Bidify.Domain.Person

  @type id_t :: integer
  @type t :: %Person{id: id_t}
  defstruct id: nil
end
