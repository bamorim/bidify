defimpl Phoenix.HTML.Safe, for: Bidify.Domain.Money do
  def to_iodata(%Bidify.Domain.Money{amount: a, currency: c}) do
    "#{prefix(c)}#{format(a)}#{suffix(c)}"
  end

  def format(i) do
    "#{i/100}"
  end

  def prefix(:brl), do: "R$ "
  def prefix(:usd), do: "$ "
  def prefix(_), do: ""

  def suffix(:gbp), do: " £"
  def suffix(_), do: ""
end
