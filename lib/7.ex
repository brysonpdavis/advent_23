defmodule Day7 do
  def part_1 do
    read_file()
    |> parse_file_into_hands_with_bets()
    |> Enum.sort(&hand_sorter/2)
    |> Enum.with_index(fn {_, bet}, idx -> bet * (idx + 1) end)
    |> Enum.sum()
  end

  def part_2 do
    read_file()
    |> parse_file_into_hands_with_bets()
    |> Enum.sort(&hand_sorter_new/2)
    |> Enum.with_index(fn {_, bet}, idx -> bet * (idx + 1) end)
    |> Enum.sum()
  end

  def read_file do
    File.read!("lib/7.txt")
  end

  defp parse_file_into_hands_with_bets(file_string) do
    String.split(file_string, "\n", trim: true)
    |> Enum.map(&parse_hand_with_bet_from_line/1)
  end

  defp parse_hand_with_bet_from_line(line) do
    String.split(line, " ", trim: true)
    |> case do
      [hand, bet] ->
        {hand, String.to_integer(bet)}
    end
  end

  # returns true if second hand is stronger than first
  defp hand_sorter(hand_1, hand_2) do
    {cards_1, _} = hand_1
    {cards_2, _} = hand_2

    strength_1 = hand_strength(hand_1)
    strength_2 = hand_strength(hand_2)

    case strength_1 == strength_2 do
      false ->
        strength_2 > strength_1

      true ->
        tie_breaker(cards_1, cards_2, &get_priority/1)
    end
  end

  defp hand_sorter_new(hand_1, hand_2) do
    {cards_1, _} = hand_1
    {cards_2, _} = hand_2

    strength_1 = hand_strength_new(hand_1)
    strength_2 = hand_strength_new(hand_2)

    case strength_1 == strength_2 do
      false ->
        strength_2 > strength_1

      true ->
        tie_breaker(cards_1, cards_2, &get_priority_new/1)
    end
  end

  defp hand_strength_new(hand) do
    {cards, _} = hand

    graphemes = String.graphemes(cards)

    jokers = graphemes |> Enum.filter(fn card -> card == "J" end) |> Enum.count()

    matches = graphemes |> Enum.filter(fn card -> card != "J" end) |> Enum.reduce(%{}, fn card, acc ->
      Map.update(acc, card, 1, &(&1 + 1))
    end) |> Map.values() |> Enum.sort(:desc)

    case matches do
      [] -> [jokers]
      [h | rest] -> [h + jokers | rest]
    end
  end

  # higher number === stronger hand
  defp hand_strength(hand) do
    {cards, _} = hand

    matches =
      String.graphemes(cards)
      |> Enum.reduce(%{}, fn card, acc ->
        Map.update(acc, card, 1, &(&1 + 1))
      end)
      |> Map.values()
      |> Enum.sort(:desc)

    case matches do
      [5] -> 6
      [4, 1] -> 5
      [3, 2] -> 4
      [3, 1, 1] -> 3
      [2, 2, 1] -> 2
      [2, 1, 1, 1] -> 1
      [1, 1, 1, 1, 1] -> 0
    end
  end

  @priorities ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]

  defp get_priority(card) do
    Enum.find_index(
      @priorities,
      &(&1 == card)
      )
    end

  @new_priorities ["J", "2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"]

  defp get_priority_new(card) do
    Enum.find_index(
      @new_priorities,
      &(&1 == card)
    )
  end

  # returns true if second hand is stronger than first
  defp tie_breaker(cards_1, cards_2, func) when is_binary(cards_1) and is_binary(cards_2) do
    tie_breaker(String.graphemes(cards_1), String.graphemes(cards_2), func)
  end

  defp tie_breaker([], [], _) do
    false
  end

  defp tie_breaker([c1 | cs1], [c2 | cs2], func) do
    case c1 == c2 do
      true ->
        tie_breaker(cs1, cs2, func)

      false ->
        func.(c2) > func.(c1)
    end
  end
end
