defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """

  def frequency([], _workers), do: %{}
  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, _workers) do
    input = flatten(texts)

    cond do
      Enum.count(input) == 0 ->
        %{}

      true ->
        # strang = " jsdfk sjfdjsfjsdfjk sjf I am the very model of a modern " |> String.replace(" ","")
        keys =
          input
          |> Enum.uniq()
          |> Enum.filter(fn el -> el != "" end)

        Enum.flat_map(keys, fn x -> %{x => Enum.count(input, fn y -> y == x end)} end)
    end
  end

  @spec flatten([String.t()]) :: list
  defp flatten(list_strings) do
    Enum.join(list_strings) |> String.replace(" ", "") |> String.downcase() |> String.split("")
  end
end
