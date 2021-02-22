defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @numbers ~w(1 2 3 4 5 5 6 7 9 )
  @blacklist_chars [" ", "!", "*", "?", "&", ",", ".", ";", ":", "\n", "\t"]

  def frequency([], _workers), do: %{}

  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, _workers) do
    input = flatten(texts)
    keys = generate_keys(input)

    Enum.flat_map(keys, fn x -> %{x => Enum.count(input, fn y -> y == x end)} end)
  end

  @spec generate_keys([String.t()]) :: list
  defp generate_keys(input) do
    input
    |> Enum.uniq()
    |> Enum.filter(fn el -> el != "" end)
  end

  @spec flatten([String.t()]) :: list
  defp flatten(list_strings) do
    pattern = :binary.compile_pattern(@blacklist_chars ++ @numbers)

    Enum.join(list_strings)
    |> String.replace(pattern, "")
    |> String.downcase()
    |> String.split("")
  end
end
