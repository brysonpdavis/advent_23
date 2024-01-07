defmodule Day6 do
  def part_1 do
    read_file()
    |> parse_times_and_distances_from_file_string()
    |> Enum.map(&find_num_winning_strategies_for_race/1)
    |> Enum.product()
  end

  def part_2 do
    read_file()
    |> parse_one_time_and_distance_from_file_string()
    |> find_num_winning_strategies_for_race()
  end

  def part_2_fast do
    read_file()
    |> parse_one_time_and_distance_from_file_string()
    |> case do
      {time, dist} ->
        first_winning_strategy = Enum.find(1..time, &time_held_is_winning?(time, dist, &1))
        last_winning_strategy = Enum.find(time..1, &time_held_is_winning?(time, dist, &1))

        last_winning_strategy - first_winning_strategy + 1
    end
  end

  defp find_num_winning_strategies_for_race({time, dist})
       when is_integer(time) and is_integer(dist) do

    Stream.filter(1..time, &time_held_is_winning?(time, dist, &1))
    |> Enum.count()
  end

  defp time_held_is_winning?(time, dist, ms_held) do
    time_remaining = time - ms_held
    speed = ms_held

    time_remaining * speed > dist
  end

  @spec parse_times_and_distances_from_file_string(String.t()) :: [{integer(), integer()}]
  defp parse_times_and_distances_from_file_string(file_string) do
    String.split(file_string, "\n", trim: true)
    |> Enum.map(&parse_ints_from_line/1)
    |> Enum.zip()
  end

  defp parse_one_time_and_distance_from_file_string(file_string) do
    String.split(file_string, "\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, ":")
      |> Enum.at(1)
      |> String.split(" ", trim: true)
      |> Enum.join()
      |> String.to_integer()
    end)
    |> case do
      [time, dist] -> {time, dist}
      _ -> raise "Expected exactly one line in file"
    end
  end

  @spec parse_ints_from_line(String.t()) :: [integer()]
  defp parse_ints_from_line(line) do
    String.split(line, ":")
    |> Enum.at(1)
    |> String.split(" ", trim: true)
    |> Enum.map(fn str -> String.to_integer(str) end)
  end

  @spec read_file() :: String.t()
  defp read_file do
    File.read!("lib/6.txt")
  end
end
