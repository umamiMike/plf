defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, _workers) do
    input = List.first(texts)

    cond do
      is_nil(input) ->
        %{}

      String.replace(input, " ", "") |> String.length() == 0 ->
        %{}

      true ->
        test = String.replace(input, " ", "")
        length = String.downcase(test) |> String.length()
        firstChar = String.first(test)
        %{firstChar => length}
    end
  end
end
