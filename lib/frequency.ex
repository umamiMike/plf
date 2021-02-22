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
  def frequency(texts, workers) do
    input = conform(texts)
    keys = generate_keys(input)

    Enum.map(keys, fn key -> %{key => input} end)
    |> start_stream(workers)
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

  @spec start_stream([Map.t()], number) :: Enumerable.t()
  defp start_stream(list_map, workers) do
    Enum.chunk_every(list_map, :erlang.ceil(workers))
    |> Task.async_stream(&get_count/1)
  end

  defp get_count(maps) do
    maps
    |> Enum.reduce(%{}, fn map, acc ->
      key = Map.keys(map) |> List.first()
      updated = Map.update(map, key, 0, fn vlist -> Enum.count(vlist, fn it -> it == key end) end)
      Map.merge(acc, updated)
    end)
  end

  defp merge_stream(results_stream) do
    Enum.reduce(results_stream, %{}, fn {:ok, result}, acc ->
      Map.merge(acc, result)
    end)
  end

  @spec generate_keys([String.t()]) :: list
  defp generate_keys(input) do
    input
    |> Enum.uniq()
    |> Enum.filter(fn el -> el != "" end)
  end
end
