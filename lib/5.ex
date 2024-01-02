defmodule SeedMaps do
  defstruct maps: [], seeds: []

  @spec parse_sections(list(list(binary()))) :: %SeedMaps{}
  def parse_sections(sections) when is_list(sections) do
    %SeedMaps{
      seeds: parse_seeds(hd(sections)),
      maps: Enum.map(tl(sections), &parse_map_from_section/1)
    }
  end

  @spec parse_seeds(list(binary())) :: list(integer())
  def parse_seeds([line]) do
    String.split(line, [" "])
    |> Enum.map(fn word ->
      case Integer.parse(word) do
        {n, _} -> n
        :error -> :nan
      end
    end)
    |> Enum.filter(&(&1 != :nan))
  end

  # datatype of the returned list is [{Range.t(), integer()}] where the first element of the
  # tuple is the range of the key and the second element is the key offset for the output
  @spec parse_map_from_section(list(binary())) :: list({Range.t(), integer()})
  defp parse_map_from_section(section) when is_list(section) do
    Enum.filter(section, &(!String.contains?(&1, "map:")))
    |> Enum.map(&parse_line_of_ints/1)
    |> Enum.map(fn [destination_start, source_start, range_length] ->
      {source_start..(source_start + range_length), destination_start - source_start}
    end)
  end

  @spec parse_line_of_ints(binary()) :: list(integer() | :nan)
  defp parse_line_of_ints(line) do
    line
    |> String.split(" ")
    |> Enum.map(fn word ->
      case Integer.parse(word) do
        {n, _} -> n
        :error -> :nan
      end
    end)
    |> Enum.filter(&(&1 != :nan))
  end
end

defmodule Day5 do
  def part_1 do
    with {:ok, file_text} <- File.read("lib/5.txt") do
      String.split(file_text, "\n\n")
      |> Enum.map(&String.split(&1, "\n"))
      |> SeedMaps.parse_sections()
      |> reduce_seeds()
    end
  end

  def part_2 do
    with {:ok, file_text} <- File.read("lib/5.txt") do
      String.split(file_text, "\n\n")
      |> Enum.map(&String.split(&1, "\n"))
      |> SeedMaps.parse_sections()
      |> reduce_seed_ranges()
    end
  end

  defp ranges_from_list_of_ints(list_of_ints) do
    case list_of_ints do
      [first, second | rest] ->
        first..second |> Stream.concat(ranges_from_list_of_ints(rest))

      [] ->
        []
    end
  end

  @spec reduce_seed_ranges(%SeedMaps{}) :: integer()
  defp reduce_seed_ranges(%SeedMaps{maps: maps, seeds: seeds}) do
    all_seeds = ranges_from_list_of_ints(seeds)

    reduce_seeds(%SeedMaps{seeds: all_seeds, maps: maps})
  end

  @spec reduce_seeds(%SeedMaps{}) :: integer()
  defp reduce_seeds(%SeedMaps{maps: maps, seeds: seeds}) do
    Stream.map(seeds, fn seed ->
      IO.inspect(seed)

      Enum.reduce(maps, seed, fn map, acc ->
        {_, offset} = Enum.find(map, {:nothing, 0}, &(acc in elem(&1, 0)))
        acc + offset
      end)
    end)
    |> Enum.min()
  end
end
