defmodule Day13 do
  def part1 do
    read_file()
    |> parse_file_into_sections()
    |> transpose_all_sections()
    |> Enum.map(&find_horizontal_and_vertical_reflection_points/1)
    |> IO.inspect()
    |> Enum.map(fn {r1, r2} -> r1 + r2 * 100 end)
    |> Enum.sum()
  end

  def part2 do
    read_file()
    |> parse_file_into_sections()
    |> transpose_all_sections()
    |> Enum.map(
      &find_horizontal_and_vertical_reflection_points(
        &1,
        fn l -> find_reflection_point_in_section_with_smudge(l) end
      )
    )
    |> IO.inspect()
    |> Enum.map(fn {r1, r2} -> r1 + r2 * 100 end)
    |> Enum.sum()
  end

  defp read_file do
    File.read!("lib/13.txt")
  end

  defp parse_file_into_sections(file_string) do
    file_string
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn section ->
      String.split(section, "\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))
    end)
  end

  defp transpose_2d_array(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp transpose_all_sections(sections) do
    sections
    |> Enum.map(&transpose_2d_array/1)
  end

  defp find_horizontal_and_vertical_reflection_points(
         list_of_lists,
         reflection_finder \\ &find_reflection_point_in_section/1
       ) do
    h_ref_point = reflection_finder.(list_of_lists)

    v_ref_point =
      list_of_lists
      |> transpose_2d_array()
      |> reflection_finder.()

    {h_ref_point, v_ref_point}
  end

  defp find_reflection_point_in_section(list_of_lists) do
    list_of_lists
    |> Enum.with_index()
    |> Enum.find({nil, -1}, fn {_row, row_idx} ->
      is_reflection_at_index?(list_of_lists, row_idx)
    end)
    |> (fn {_, i} -> i + 1 end).()
  end

  defp is_reflection_at_index?(list_of_lists, idx) do
    following_els = Enum.slice(list_of_lists, (idx + 1)..-1//1)

    zipped =
      Enum.slice(list_of_lists, 0..idx)
      |> Enum.reverse()
      |> Enum.zip(following_els)

    length(zipped) > 0 && Enum.all?(zipped, fn {r1, r2} -> r1 == r2 end)
  end

  defp find_reflection_point_in_section_with_smudge(list_of_lists) do
    list_of_lists
    |> Enum.with_index()
    |> Enum.find({nil, -1}, fn {_row, row_idx} ->
      count_differences_in_rows_reflected_from_index(list_of_lists, row_idx)
    end)
    |> (fn {_, i} -> i + 1 end).()
  end

  defp count_differences_in_rows_reflected_from_index(list_of_lists, idx) do
    following_els = Enum.slice(list_of_lists, (idx + 1)..-1//1)

    zipped =
      Enum.slice(list_of_lists, 0..idx)
      |> Enum.reverse()
      |> Enum.zip(following_els)

    differences =
      zipped
      |> Enum.map(fn {r1, r2} -> Enum.zip(r1, r2) end)
      |> Enum.map(fn zipped_rows -> Enum.filter(zipped_rows, fn {el1, el2} -> el1 != el2 end) end)
      |> Enum.map(&length/1)
      |> Enum.sum()

    differences == 1
  end
end
