defmodule Day1 do
  defp read_file do
    File.read!("lib/1.txt")
  end

  defp split_into_lines(f) do
    String.split(f, "\n")
  end

  defp split_into_chars(l) do
    String.split(l, "")
  end

  defp filter_out_non_numbers(l) do
    Enum.filter(l, fn c -> Integer.parse(c) != :error end)
  end

  defp parse_number(l) do
    (List.first(l, "0") <> List.last(l, "0")) |> Integer.parse() |> elem(0)
  end

  defp sum(l) when is_list(l) do
    Enum.sum(l)
  end

  defp transform_line_to_integers(l) do
    split_into_chars(l)
    |> filter_out_non_numbers()
    |> parse_number()
  end

  def parse_calibration_values do
    read_file()
    |> split_into_lines()
    |> Enum.map(&transform_line_to_integers/1)
    |> sum()
  end

  @digit_map %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  defp replace_and_transform_lines(ls) do
    Enum.map(ls, &replace_digits_in_line/1)
    |> Enum.map(&transform_line_to_integers/1)
  end

  # must replace the digit with the number word on both sides to preserve any numbers that share chars with k
  defp replace_first_digit_in_line(line) do
    String.replace(line, Map.keys(@digit_map), fn k -> k <> Map.get(@digit_map, k) <> k end, global: false)
  end

  defp replace_last_digit_in_line(line) do
    String.reverse(line)
    |> String.replace(
      Enum.map(Map.keys(@digit_map), &String.reverse/1),
      fn k -> k <> Map.get(@digit_map, String.reverse(k)) <> k end,
      global: false
    )
    |> String.reverse()
  end

  defp replace_digits_in_line(line) when is_binary(line) do
    replace_first_digit_in_line(line)
    |> replace_last_digit_in_line()
  end

  def parse_calibration_values_2 do
    read_file()
    |> split_into_lines()
    |> replace_and_transform_lines()
    |> sum()
  end
end
