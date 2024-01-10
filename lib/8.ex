defmodule Day8 do
  def part_1 do
    read_file()
    |> parse_file()
    |> run_instructions("AAA", fn {cur_node, _} ->
      cur_node == "ZZZ"
    end)
  end

  def part_2 do
    read_file()
    |> parse_file()
    |> run_in_parallel()
  end

  def part_2_fast do
    read_file()
    |> parse_file()
    |> run_with_lcm()
  end

  defp read_file() do
    File.read!("lib/8.txt")
  end

  defp parse_file(file_string) do
    [lr_instructions_line | mapping_lines] = String.split(file_string, "\n", trim: true)

    lr_instructions = String.split(lr_instructions_line, "", trim: true)

    instructions_map =
      Enum.map(mapping_lines, fn <<a, b, c>> <>
                                   " = (" <> <<i, j, k>> <> ", " <> <<x, y, z>> <> ")" ->
        {to_string([a, b, c]), to_string([i, j, k]), to_string([x, y, z])}
      end)
      |> Enum.reduce(%{}, fn {start, l, r}, acc ->
        Map.put(acc, start, {l, r})
      end)

    {lr_instructions, instructions_map}
  end

  @spec iterate_until(any(), (any() -> any()), any(), any()) :: integer()
  defp iterate_until(mapping_func, condition_func, current_value, iteration \\ 0) do
    if condition_func.(current_value) do
      iteration
    else
      IO.inspect(iteration)
      iterate_until(mapping_func, condition_func, mapping_func.(current_value), iteration + 1)
    end
  end

  defp run_instructions({full_instructions, instructions_map}, starting_node, success_func) do
    mapping_func = fn {cur_node, cur_instructions} ->
      [l_or_r | remaining_instructions] =
        case cur_instructions do
          [] -> full_instructions
          _ -> cur_instructions
        end

      {l, r} = instructions_map[cur_node]

      next_node =
        case l_or_r do
          "L" -> l
          "R" -> r
        end

      {next_node, remaining_instructions}
    end

    iterate_until(mapping_func, success_func, {starting_node, []})
  end

  defp run_in_parallel({full_instructions, instructions_map}) do
    starting_nodes =
      Map.keys(instructions_map)
      |> Enum.filter(fn
        <<_, _>> <> "A" -> true
        _ -> false
      end)

    IO.inspect(starting_nodes)

    map_one = fn cur_node, l_or_r ->
      {l, r} = instructions_map[cur_node]

      case l_or_r do
        "L" -> l
        "R" -> r
      end
    end

    map_all = fn {cur_nodes, cur_instructions} ->
      # IO.inspect(cur_nodes)

      [l_or_r | remaining_instructions] =
        case cur_instructions do
          [] -> full_instructions
          _ -> cur_instructions
        end

      new_nodes = Enum.map(cur_nodes, &map_one.(&1, l_or_r))

      {new_nodes, remaining_instructions}
    end

    condition_func = fn {cur_nodes, _} ->
      Enum.all?(cur_nodes, fn
        <<_, _>> <> "Z" -> true
        _ -> false
      end)
    end

    iterate_until(map_all, condition_func, {starting_nodes, []})
  end

  defp lcm(x, y) when is_integer(x) and is_integer(y) do
    div(x * y, Integer.gcd(x, y))
  end

  defp run_with_lcm({full_instructions, instructions_map}) do
    condition_func = fn {cur_node, _} ->
      case cur_node do
        <<_, _>> <> "Z" -> true
        _ -> false
      end
    end

    Map.keys(instructions_map)
    |> Enum.filter(fn
      <<_, _>> <> "A" -> true
      _ -> false
    end)
    |> Enum.map(&run_instructions({full_instructions, instructions_map}, &1, condition_func))
    |> Enum.reduce(&lcm/2)
  end
end
