defmodule Round do
  defstruct red: 0, green: 0, blue: 0

  def combine_rounds(round1, round2) do
    %Round{
      red: max(round1.red, round2.red),
      green: max(round1.green, round2.green),
      blue: max(round1.blue, round2.blue)
    }
  end

  def is_round(maybe_round) do is_struct(maybe_round, Round) end

  def is_valid_round(maybe_round) do
    is_round(maybe_round) and maybe_round.red <= 12 and maybe_round.green <= 13 and maybe_round.blue <= 14
  end

  def parse_rounds(rounds) when is_binary(rounds) do
    String.split(rounds, ";")
    |> Enum.map(&parse_color_counts_string_into_round/1)
  end

  defp parse_color_counts_string_into_round(color_counts) when is_binary(color_counts) do
    String.split(color_counts, ",")
    |> Enum.map(
      &(String.trim(&1) |> String.split(" ") |> fn [count, color] -> atomic_round(color, count) end.()
      )
    )
    |> Enum.reduce(%Round{}, &combine_rounds(&1, &2))
  end

  defp atomic_round(color, count) do
    count_int = String.to_integer(count)

    case color do
      "red" -> %Round{red: count_int, green: 0, blue: 0}
      "green" -> %Round{red: 0, green: count_int, blue: 0}
      "blue" -> %Round{red: 0, green: 0, blue: count_int}
    end
  end
end

defmodule Game do
  defstruct game_id: 0, rounds: []

  def is_valid_game(game) when is_struct(game) do
    Enum.reduce(game.rounds, true, fn (round, acc) -> acc and Round.is_valid_round(round) end )
  end

  def parse_line_to_game(line) when is_binary(line) do
    case String.split(line, ":") do
      [header, body] ->
        %Game{game_id: get_game_id_from_header(header), rounds: Round.parse_rounds(body)}
    end
  end

  defp get_game_id_from_header(header) when is_binary(header) do
    String.split(header, " ") |> fn [_, t] -> Integer.parse(t) end.() |> elem(0)
  end

  def compute_min_round(%Game{rounds: rounds}) when is_list(rounds) do
    Enum.reduce(rounds, %Round{}, &Round.combine_rounds(&1, &2))
  end

end

defmodule Day2 do
  def sum_possible_games do
    parse_file_to_games()
    |> filter_impossible_games()
    |> Enum.reduce(0, &(&1.game_id + &2))
  end

  def sum_game_min_powers do
    parse_file_to_games()
    |> map_games_to_power()
    |> Enum.sum()
  end

  defp map_games_to_power(games) when is_list(games) do
    map_games_to_min_round(games)
    |> map_min_rounds_to_power()
  end

  defp map_games_to_min_round(games) when is_list(games) do
    Enum.map(games, &Game.compute_min_round/1)
  end

  defp map_min_rounds_to_power(min_rounds) when is_list(min_rounds) do
    Enum.map(min_rounds, &(&1.red * &1.green * &1.blue))
  end

  defp read_file do
    File.read!("lib/2.txt")
  end

  defp parse_file_to_games do
    read_file()
    |> String.split("\n")
    |> Enum.map(&Game.parse_line_to_game/1)
  end

  defp filter_impossible_games(games) when is_list(games) do
    Enum.filter(games, &Game.is_valid_game/1)
  end
end
