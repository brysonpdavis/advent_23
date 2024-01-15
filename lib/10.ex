defmodule Day10 do
  def part_1 do
    map =
      read_file()
      |> parse_file_into_map()

    find_start_from_map(map)
    |> find_loop_length(map)
    |> div(2)
    |> Kernel.+(1)
  end

  defp read_file do
    File.read!("lib/10.txt")
  end

  defp parse_file_into_map(file_str) do
    file_str
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Enum.with_index(fn v, row ->
      Enum.with_index(v, fn c, col -> %{{row, col} => c} end)
      |> Enum.reduce(%{}, &Map.merge/2)
    end)
    |> Enum.reduce(%{}, &Map.merge/2)
  end

  defp find_start_from_map(map) when is_map(map) do
    with {position, _} <- Enum.find(map, fn {_, char} -> char == "S" end) do
      position
    end
  end

  defp find_next_from_start({row, col}, map) do
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.find(fn {dr, dc} ->
      char = map[{dr + row, dc + col}]

      valid_chars_by_relative_position = %{
        {-1, 0} => ["7", "F", "|"],
        {1, 0} => ["L", "J", "|"],
        {0, -1} => ["F", "L", "-"],
        {0, 1} => ["7", "J", "-"]
      }

      Enum.any?(valid_chars_by_relative_position[{dr, dc}], &(&1 == char))
    end)
    |> (fn {dr, dc} -> {row + dr, col + dc} end).()
  end

  defp find_loop_length(start, map) do
    find_loop_length(start, map, 0, MapSet.new())
  end

  defp find_loop_length(position, map, iterations, visited) do
    {row, col} = position

    next_position =
      case map[position] do
        "S" ->
          if MapSet.member?(visited, position) do
            nil
          else
            find_next_from_start(position, map)
          end

        "F" ->
          Enum.find([{row, col + 1}, {row + 1, col}], &(!MapSet.member?(visited, &1)))

        "7" ->
          Enum.find([{row, col - 1}, {row + 1, col}], &(!MapSet.member?(visited, &1)))

        "J" ->
          Enum.find([{row, col - 1}, {row - 1, col}], &(!MapSet.member?(visited, &1)))

        "L" ->
          Enum.find([{row, col + 1}, {row - 1, col}], &(!MapSet.member?(visited, &1)))

        "-" ->
          Enum.find([{row, col + 1}, {row, col - 1}], &(!MapSet.member?(visited, &1)))

        "|" ->
          Enum.find([{row - 1, col}, {row + 1, col}], &(!MapSet.member?(visited, &1)))
      end

    case next_position do
      nil ->
        print_loop(map, visited)
        iterations

      _ ->
        find_loop_length(next_position, map, iterations + 1, MapSet.put(visited, position))
    end
  end

  defp print_loop(map, visited) do
    rows = Enum.map(map, fn {{row, _}, _} -> row end) |> Enum.max()
    cols = Enum.map(map, fn {{_, col}, _} -> col end) |> Enum.max()

    grid =
      0..rows
      |> Enum.map(fn row ->
        Enum.map(0..cols, fn col ->
          if MapSet.member?(visited, {row, col}) do
            "0"
          else
            map[{row, col}]
          end
        end)
        |> Enum.join()
      end)
      |> Enum.join("\n")

    File.write("lib/10_path.txt", grid)
  end
end
