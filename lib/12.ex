defmodule Day12 do
  def part1 do
    read_file()
    |> parse_file_into_char_lists()
    |> find_permutations()
    |> trim_starting_dots_from_all()
    |> filter_impossible_conditions()
    |> length()
  end

  def part2 do
    read_file()
    |> parse_file_into_char_lists()
    |> expand()

    # |> find_permutations()
    |> trim_starting_dots_from_all()
    |> filter_impossible_conditions()
    |> length()
  end

  defp expand(list) do
    list
    |> Enum.map(fn {damaged_conditions, correct_conditions} ->
      expanded_damaged_conditions =
        damaged_conditions
        |> List.duplicate(5)
        |> Enum.intersperse("?")
        |> List.flatten()

      expanded_correct_conditions =
        correct_conditions
        |> List.duplicate(5)
        |> List.flatten()

      {expanded_damaged_conditions, expanded_correct_conditions}
    end)
  end

  defp read_file do
    File.read!("lib/12.txt")
  end

  defp trim_starting_dots_from_all(conditions) do
    conditions
    |> Enum.map(fn {damaged_conditions, correct_conditions} ->
      {trim_starting_dots(damaged_conditions), correct_conditions}
    end)
  end

  defp trim_starting_dots(char_list) do
    case char_list do
      ["." | rest] ->
        trim_starting_dots(rest)

      _ ->
        char_list
    end
  end

  @spec parse_file_into_char_lists(String.t()) :: [{list(), list()}]
  defp parse_file_into_char_lists(file_str) do
    file_str
    |> String.split("\n")
    |> Enum.map(
      &(String.split(&1, " ", trim: true)
        |> case do
          [damaged_conditions, correct_conditions] ->
            {
              String.split(damaged_conditions, "", trim: true),
              String.split(correct_conditions, ",")
              |> Enum.map(fn str -> String.to_integer(str) end)
            }
        end)
    )
  end

  @spec find_permutations([{list(), list()}]) :: [{list(), list()}]
  defp find_permutations(conditions_tuples_list) do
    conditions_tuples_list
    |> Enum.flat_map(fn {damaged_conditions, correct_conditions} ->
      damaged_conditions_to_permutations(damaged_conditions)
      |> Enum.map(fn conds -> {conds, correct_conditions} end)
    end)
  end

  defp filter_impossible_conditions(conditions_tuples_list) do
    conditions_tuples_list
    |> Enum.filter(&are_damaged_conditions_possible?/1)
  end

  defp damaged_conditions_to_permutations(damaged_conditions) do
    case damaged_conditions do
      ["?" | rest] ->
        remaining_permuations = damaged_conditions_to_permutations(rest)

        Enum.flat_map(remaining_permuations, fn permutation ->
          [["." | permutation], ["#" | permutation]]
        end)

      [c | rest] ->
        damaged_conditions_to_permutations(rest)
        |> Enum.map(fn permutation -> [c | permutation] end)

      [] ->
        [[]]
    end
  end

  defp are_damaged_conditions_possible?({damaged_conditions, correct_conditions}) do
    case {damaged_conditions, correct_conditions} do
      {[], []} ->
        true

      {[], [0]} ->
        true

      {[], [_ | _]} ->
        false

      {["#" | _], []} ->
        false

      {["#" | _], [0 | _]} ->
        false

      {["#" | rest_damaged], [n | rest_correct]} ->
        are_damaged_conditions_possible?({rest_damaged, [n - 1 | rest_correct]})

      {["." | rest_damaged], []} ->
        are_damaged_conditions_possible?({rest_damaged, []})

      {["." | rest_damaged], [0 | rest_correct]} ->
        are_damaged_conditions_possible?({trim_starting_dots(rest_damaged), rest_correct})

      {["." | _], [_ | _]} ->
        false
    end
  end
end
