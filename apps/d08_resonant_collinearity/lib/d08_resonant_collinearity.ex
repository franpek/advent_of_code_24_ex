defmodule ResonantCollinearity do
  @moduledoc """
  Documentation for `ResonantCollinearity`.
  """

  @doc """
  Return the locations that presents an antinode based on the antennas.

  ## ResonantCollinearity

      iex> ResonantCollinearity.antinode_locations("files/example.txt")
      14

      iex> ResonantCollinearity.antinode_locations("files/sample.txt")
      x

  """
  def antinode_locations(path) do
    matrix = File.read!(path)
    |> String.split("\r\n")
    |> Enum.with_index
    |> Enum.map(fn {row, y} -> String.codepoints(row) |> Enum.with_index |> Enum.map(fn {val, x} -> {val, x, y} end) end)

    antennas = matrix
    |> Enum.map(fn row -> Enum.filter(row, fn {element, _, _} -> element != "." end) end)
    |> List.flatten()
    |> Enum.sort
    |> Enum.group_by(fn {val, _, _} -> val end)

    antinodes = antennas
    |> Enum.map(fn {_frequency, antennas} -> get_antinodes_from_antennas(antennas) end)
    |> Enum.map(fn antinodes_by_frequency -> antinodes_by_frequency |> List.flatten end)

    max_x = matrix |> hd |> (fn row -> Enum.count(row) end).()
    max_y = matrix |> (fn matrix -> Enum.count(matrix) end).()

    antinodes
    |> List.flatten
    |> IO.inspect
    |> Enum.filter( fn antinodes_by_frequency -> is_in_matrix(max_x, max_y, antinodes_by_frequency) end )
    |> Enum.uniq
    |> Enum.count
  end

  defp get_antinodes_from_antennas(antennas, antinodes \\ [])
  defp get_antinodes_from_antennas([], _), do: []
  defp get_antinodes_from_antennas([current_item | antennas_left], antinodes) do

    current_item_combinations = antennas_left
    |> Enum.map(fn combination -> get_antinodes_from_antennas_pair(current_item, combination) end)

    [current_item_combinations | get_antinodes_from_antennas(antennas_left, antinodes)]
  end

  def get_antinodes_from_antennas_pair({_val1, x1, y1},{_val2, x2, y2}) do
    left_node = {2*x1-x2, 2*y1-y2}
    right_node = {2*x2-x1, 2*y2-y1}
    [left_node, right_node]
  end

  def is_in_matrix(max_x, max_y, _node = {x,y}) when x >= 0 and y >= 0 and x < max_x and y < max_y, do: true
  def is_in_matrix(_max_x, _max_y, _node), do: false

end
