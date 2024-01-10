defmodule PartNumber do
  defstruct coord: {0, 0}, length: 0, value: 0

  def from_digits_and_coord(digits, coord) when is_list(digits) and is_struct(coord, Coord) do
    %PartNumber{value: num_from_digits(digits), coord: coord, length: length(digits)}
  end

  defp num_from_digits(digits) when is_list(digits) do
    int_s = Enum.reverse(digits) |> Enum.join()

    case Integer.parse(int_s) do
      {n, _} -> n
      :error -> IO.inspect(digits)
    end
  end
end

defmodule Coord do
  defstruct x: 0, y: 0

  def from_tuple({x, y}) when is_integer(x) and is_integer(y) do
    %Coord{x: x, y: y}
  end

  def from_part_number(%PartNumber{coord: {x, y}}) when is_integer(x) and is_integer(y) do
    %Coord{x: x, y: y}
  end

  def are_adjacent?(%Coord{x: x, y: y}, %Coord{x: xx, y: yy}) do
    abs(x - xx) <= 1 and abs(y - yy) <= 1
  end

  def are_adjacent?(coord1, coord2, length)
      when is_struct(coord1, Coord) and is_struct(coord2, Coord) and is_integer(length) do
    Enum.reduce(0..length, false, fn x_add, acc -> are_adjacent?(coord1, add_x(coord2, x_add)) or acc end)
  end

  defp add_x(%Coord{x: x, y: y}, x_add) when is_integer(x) and is_integer(y) and is_integer(x_add) do
    %Coord{x: x + x_add, y: y}
  end
end

defmodule Day3 do
  def part1 do
    alternate_symbols_coords = gather_alternate_symbols()

    read_file()
    |> file_string_to_2d_array()
    |> Enum.with_index(&gather_numbers_in_row(&1, [], [], 0, &2) |> Enum.reverse())
    |> List.flatten()
    |> Enum.filter(fn %PartNumber{length: l, coord: coord} ->
      Enum.any?(alternate_symbols_coords, &Coord.are_adjacent?(elem(&1, 1), coord, l))
    end)
    # |> length()
    |> Enum.map(&(&1.value)) |> Enum.sum()
  end

  defp read_file do
    File.read!("lib/3.txt")
  end

  defp file_string_to_2d_array(file_string) when is_binary(file_string) do
    file_string
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  def gather_alternate_symbols do
    read_file()
    |> file_string_to_2d_array()
    |> Enum.with_index(fn cs, j ->
      Enum.with_index(cs, fn c, i ->
        case Integer.parse(c) do
          :error ->
            case c do
              "." -> :none
              _ -> {c, %Coord{x: i, y: j}}
            end

          _ ->
            :none
        end
      end)
    end)
    |> List.flatten()
    |> Enum.filter(fn
      :none -> false
      _ -> true
    end)
  end

  defp gather_numbers_in_row(row, current_num_digits, nums_acc, i, j)
       when is_list(row) and is_list(current_num_digits) and is_list(nums_acc) and is_integer(i) do
    case {row, current_num_digits} do
      {[], []} ->
        nums_acc

      {[], digits} ->
        [PartNumber.from_digits_and_coord(digits, %Coord{x: i - length(digits), y: j}) | nums_acc]

      {[h | t], []} ->
        case Integer.parse(h) do
          :error ->
            gather_numbers_in_row(t, [], nums_acc, i + 1, j)

          _ ->
            gather_numbers_in_row(t, [h], nums_acc, i + 1, j)
        end

      {[h | t], digits} ->
        case Integer.parse(h) do
          :error ->
            new_acc = [
              PartNumber.from_digits_and_coord(digits, %Coord{x: i - length(digits), y: j})
              | nums_acc
            ]

            gather_numbers_in_row(t, [], new_acc, i + 1, j)

          _ ->
            gather_numbers_in_row(t, [h | digits], nums_acc, i + 1, j)
        end
    end
  end
end
