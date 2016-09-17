defprotocol Bidify.Utils.Comparable do
  @moduledoc """
  Defines something that can be compared
  """
  @dialyzer {:nowarn_function, __protocol__: 1, impl_for!: 1}
  alias Bidify.Utils.Comparable.Defaults
  @fallback_to_any true
  def compare(a,b)
  defdelegate eq(a,b), to: Defaults
  defdelegate ne(a,b), to: Defaults
  defdelegate bt(a,b), to: Defaults
  defdelegate be(a,b), to: Defaults
  defdelegate lt(a,b), to: Defaults
  defdelegate le(a,b), to: Defaults
end

defimpl Bidify.Utils.Comparable, for: Any do
  def compare(a,b) do
    cond do
      a>b -> 1
      a==b -> 0
      a<b -> -1
    end
  end
end
