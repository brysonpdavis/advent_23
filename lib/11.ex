defmodule Day11 do
  def part_1 do
    grid =
      read_file()
      |> parse_into_grid()

    empty_row_idxs = find_empty_row_idxs(grid)
    empty_col_idxs = find_empty_row_idxs(transpose(grid))

    find_galaxy_coords(grid)
    |> expand_coords(empty_row_idxs, empty_col_idxs)
    |> find_distances_for_all_coords()
    |> Enum.sum()
  end

  def part_2 do
    grid =
      read_file()
      |> parse_into_grid()

    empty_row_idxs = find_empty_row_idxs(grid)
    empty_col_idxs = find_empty_row_idxs(transpose(grid))

    find_galaxy_coords(grid)
    |> expand_coords(empty_row_idxs, empty_col_idxs, 1_000_000)
    |> find_distances_for_all_coords()
    |> Enum.sum()
  end

  defp find_empty_row_idxs(grid) do
    indexes_of_empty_or_nil = fn row, idx ->
      case empty_row?(row) do
        true -> idx
        false -> nil
      end
    end

    Enum.with_index(grid, indexes_of_empty_or_nil)
    |> Enum.filter(&(&1 != nil))
  end

  defp expand_coords(coords, empty_row_idxs, empty_col_idxs, multiplier \\ 2) do
    Enum.map(coords, &expand_coord(&1, empty_row_idxs, empty_col_idxs, multiplier))
  end

  defp expand_coord({row, col}, empty_row_idxs, empty_col_idxs, multiplier) do
    less_than_rows_count = length(Enum.filter(empty_row_idxs, &(&1 < row)))
    less_than_cols_count = length(Enum.filter(empty_col_idxs, &(&1 < col)))

    {
      row + (multiplier - 1) * less_than_rows_count,
      col + (multiplier - 1) * less_than_cols_count
    }
  end

  defp parse_into_grid(file_str) do
    String.split(file_str, "\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  defp read_file do
    File.read!("lib/11.txt")
  end

  defp empty_row?(row) do
    Enum.all?(row, &(&1 == "."))
  end

  defp find_galaxy_coords(grid) do
    grid
    |> Enum.with_index(fn row, row_idx ->
      Enum.with_index(row, fn el, col_idx ->
        case el do
          "#" -> {row_idx, col_idx}
          _ -> nil
        end
      end)
      |> Enum.filter(&(&1 != nil))
    end)
    |> Enum.concat()
  end

  defp find_distances_for_all_coords(coord_list) do
    case coord_list do
      [] ->
        []

      [coord | remaining_coords] ->
        Enum.map(remaining_coords, fn comp_coord -> find_coords_distance(coord, comp_coord) end) ++
          find_distances_for_all_coords(remaining_coords)
    end
  end

  defp find_coords_distance(coord1, coord2) do
    {row1, col1} = coord1
    {row2, col2} = coord2

    abs(row1 - row2) + abs(col1 - col2)
  end

  defp transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end
