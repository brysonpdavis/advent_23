defmodule Advent23 do
  @moduledoc """
  Documentation for `Advent23`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Advent23.hello()
      :world

  """
  def hello do
    :world
  end
  def parse_calibration_values do
    File.read("lib/1.txt")
  end
end
