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
    input = conform(texts)
    keys = generate_keys(input)

    Enum.map(keys, fn key -> %{key => input} end)
    |> start_stream()
    |> merge_stream()
  end

  @spec conform([String.t()]) :: list
  defp conform(list_strings) do
    pattern = :binary.compile_pattern(@blacklist_chars ++ @numbers)

    Enum.join(list_strings)
    |> String.downcase()
    |> String.replace(pattern, "")
    |> String.split("")
  end

  defp merge_stream(results_stream) do
    Enum.reduce(results_stream, %{}, fn {:ok, result}, acc ->
      Map.merge(acc, List.first(result))
    end)
  end

  @spec start_stream([Map.t()]) :: Enumerable.t()
  defp start_stream(list_map) do
    Task.async_stream(list_map, &get_count/1)
  end

  defp get_count(map) do
    map |> Enum.map(fn {k, list} -> %{k => Enum.count(list, fn it -> it == k end)} end)
  end

  @spec generate_keys([String.t()]) :: list
  defp generate_keys(input) do
    input
    |> Enum.uniq()
    |> Enum.filter(fn el -> el != "" end)
  end
end
