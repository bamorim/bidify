defprotocol Bidify.Shared.Entity do
  @moduledoc """
  Protocol for an entity
  """

  @dialyzer {:nowarn_function, __protocol__: 1, impl_for!: 1}
  @spec same(any, any) :: boolean
  def same(_,_)
end

defimpl Bidify.Shared.Entity, for: Any do
  def same(%{id: id1}, %{id: id2}), do: id1 == id2
end
