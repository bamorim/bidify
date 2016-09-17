# Don't know if tis is a good idea
defmodule Bidify.Utils.Comparable.Defaults do
  import Bidify.Utils.Comparable, only: [compare: 2]

  def eq(a,b), do: compare(a,b) == 0
  def ne(a,b), do: not eq(a,b)
  def bt(a,b), do: compare(a,b) == 1
  def be(a,b), do: compare(a,b) != -1
  def lt(a,b), do: compare(a,b) == -1
  def le(a,b), do: compare(a,b) != 1
end
