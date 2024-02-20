defmodule Day15 do
  def part1 do
    read_file()
    |> parse_file_into_steps()
    |> hash_steps()
    |> Enum.sum()
  end

  def part2 do
    read_file()
    |> parse_file_into_steps()
    |> steps_to_map()
    |> calc_total_focusing_power()
  end

  defp read_file, do: File.read!("lib/15.txt")

  defp parse_file_into_steps(file_string) do
    file_string
    |> String.trim()
    |> String.split(",", trim: true)
  end

  defp hash_steps(steps), do: Enum.map(steps, &hash/1)

  @hash_limit 256

  def hash(step) do
    step
    |> String.to_charlist()
    |> Enum.reduce(0, fn char_val, acc ->
      ((acc + char_val) * 17)
      |> rem(@hash_limit)
    end)
  end

  defp steps_to_map(steps) do
    steps
    |> Enum.map(&step_to_step_map/1)
    |> construct_map_from_maps()
  end

  defp step_to_step_map(step) do
    if String.contains?(step, "-") do
      label = String.trim(step, "-")
      %{op: "-", label: label, hash: hash(label)}
    else
      [label, focal] = String.split(step, "=")

      %{op: "=", label: label, hash: hash(label), focal: focal}
    end
  end

  defp construct_map_from_maps(maps) do
    init_map =
      Enum.into(Enum.map(0..255, fn x -> {x, []} end), %{})

    maps
    |> Enum.reduce(init_map, fn map, acc ->
      if map.op == "-" do
        new_box =
          Map.get(acc, map.hash)
          |> Enum.reject(fn %{label: l} -> l == map.label end)

        Map.put(acc, map.hash, new_box)
      else
        og_box = Map.get(acc, map.hash)

        new_box =
          if Enum.any?(og_box, fn %{label: l} -> l == map.label end) do
            Enum.map(og_box, fn el -> if el.label == map.label, do: map, else: el end)
          else
            og_box ++ [map]
          end

        Map.put(acc, map.hash, new_box)
      end
    end)
  end

  defp calc_focusing_power_of_box(box, box_num) do
    box
    |> Enum.with_index(fn map, idx ->
      (box_num + 1) * (idx + 1) * String.to_integer(map.focal)
    end)
  end

  defp calc_total_focusing_power(maps) do
    maps
    |> Enum.map(fn {hash, box} ->
      calc_focusing_power_of_box(box, hash)
    end)
    |> Enum.map(&Enum.sum/1)
    |> Enum.sum()
  end
end
