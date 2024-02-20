defmodule Day14 do
  def part1 do
    read_file()
    |> parse_file_into_columns()
    |> Enum.map(&transform_into_segments/1)
    |> Enum.map(&calc_load_for_transformed_column/1)
    |> Enum.sum()
  end

  defp read_file do
    File.read!("lib/14.txt")
  end

  defp parse_file_into_columns(file_string) do
    file_string
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> transpose_2d_array()
  end

  defp transpose_2d_array(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp calc_load_for_transformed_column(column) do
    column
    |> Enum.map(fn {string, acc} ->
      String.graphemes(string)
      |> Enum.filter(&(&1 == "O"))
      |> length()
      |> calc_load_for_segment(acc)
    end)
    |> Enum.sum()
  end

  defp calc_load_for_segment(num_rocks, idx) do
    case num_rocks do
      0 ->
        0

      1 ->
        get_size() - idx

      _ ->
        start_load = get_size() - idx

        start_load..(start_load - num_rocks + 1)
        |> Enum.sum()
    end
  end

  @delimiter "#"

  defp get_size(), do: read_file() |> String.split("\n", trim: true) |> length()

  defp transform_into_segments(ls) do
    Enum.join(ls, "")
    |> String.split(@delimiter)
    |> accumulate_counts()
  end

  defp accumulate_counts(strings) do
    Enum.reduce(strings, {[], 0}, fn string, {acc, count} ->
      new_count = count + String.length(string)

      {[{string, count} | acc], new_count + 1}
    end)
    |> elem(0)
    |> Enum.reverse()
  end
end
