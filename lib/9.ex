defmodule Day9 do
  def part_1 do
    read_file()
    |> parse_file()
    |> Enum.map(fn ls -> predict_next_number(ls) end)
    |> Enum.sum()
  end

  def part_2 do
    read_file()
    |> parse_file()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(fn ls -> predict_next_number(ls) end)
    |> Enum.sum()
  end

  defp read_file do
    File.read!("lib/9.txt")
  end

  defp parse_file(file_string) when is_binary(file_string) do
    String.split(file_string, "\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
    end)
  end

  defp differences([_]) do
    []
  end
  defp differences([i, j | rest]) do
    [j - i | differences([j | rest])]
  end

  defp predict_next_number(int_list) do
    case Enum.all?(int_list, &(&1 == 0)) do
      true -> 0
      false ->
        List.last(int_list) + predict_next_number(differences(int_list))
    end
  end
end
