defmodule Card do
  defstruct winning_nums: [], your_nums: []

  def parse_from_line(line) when is_binary(line) do
    case String.split(line, ":", trim: true) do
      [_, data] ->
        case String.split(data, "|", trim: true) do
          [winning_nums, your_nums] ->
            %Card{
              winning_nums: parse_digits_from_string(winning_nums),
              your_nums: parse_digits_from_string(your_nums)
            }

          _ ->
            :error
        end

      _ ->
        :error
    end
  end

  def find_matches(%Card{winning_nums: l1, your_nums: l2}) when is_list(l1) and is_list(l2) do
    Enum.filter(l1, &Enum.member?(l2, &1))
    |> length()
  end

  def calculate_value_from_matches(matches) when is_integer(matches) do
    case matches do
      0 -> 0
      n -> 2 ** (n - 1)
    end
  end

  def calculate_value(card)
      when is_struct(card, Card) do
    find_matches(card)
    |> calculate_value_from_matches()
  end

  defp parse_digits_from_string(string) when is_binary(string) do
    String.split(string, " ", trim: true)
  end
end

defmodule Day4 do
  def part_1 do
    read_and_split_file()
    |> Enum.map(&Card.parse_from_line/1)
    |> Enum.map(&Card.calculate_value/1)
    |> Enum.sum()
  end

  def part_2 do
    read_and_split_file()
    |> Enum.map(&Card.parse_from_line/1)
    |> Enum.map(&Card.find_matches/1)
    # calculate multiples
    |> Enum.sum()
  end

  defp read_and_split_file do
    File.read!("lib/4.txt")
    |> String.split("\n", trim: true)
  end
end
