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
      256

      # Second part
      iex> ResonantCollinearity.antinode_locations("files/sample.txt")
      977 # Wrong value

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

    max_x = matrix |> hd |> (fn row -> Enum.count(row) end).()
    max_y = matrix |> (fn matrix -> Enum.count(matrix) end).()

    antinodes = antennas
    |> Enum.map(fn {_frequency, antennas} -> get_antinodes_from_antennas(antennas, max_x, max_y) end)

    antinodes |> List.flatten |> Enum.uniq |> Enum.count
  end

  defp get_antinodes_from_antennas(antennas, max_x, max_y, antinodes \\ [])
  defp get_antinodes_from_antennas([], _max_x, _max_y, _), do: []
  defp get_antinodes_from_antennas([current_item | antennas_left], max_x, max_y, antinodes) do

    current_item_combinations = antennas_left
    |> Enum.map(fn combination -> get_antinodes_from_antennas_pair(current_item, combination, max_x, max_y) end)

    [current_item_combinations | get_antinodes_from_antennas(antennas_left, max_x, max_y, antinodes)]
  end

  def get_antinodes_from_antennas_pair(left_node = {_val1, x1, y1}, right_node = {_val2, x2, y2}, max_x, max_y) do

    possible_next_left_node = {2*x1-x2, 2*y1-y2}

    left_antinodes =
      if is_in_matrix(possible_next_left_node, max_x, max_y) do
        [
          {x1, y1},
          possible_next_left_node,
          get_extended_antinodes(possible_next_left_node, {x1 - x2, y1 - y2}, max_x, max_y)
        ]
      else
        []
    end

    possible_next_right_node = {2*x2-x1, 2*y2-y1}

    right_antinodes =
      if is_in_matrix(possible_next_right_node, max_x, max_y) do
        [
          {x2, y2},
          possible_next_right_node,
          get_extended_antinodes(possible_next_right_node, {x2 - x1, y2 - y1}, max_x, max_y)
        ]
      else
        []
      end

    [left_antinodes, right_antinodes]
  end

  def get_extended_antinodes(_antinode = {x,y}, next_node_length = {x_length, y_length}, max_x, max_y) do

    next_node = {x+x_length, y+y_length}

    if is_in_matrix(next_node, max_x, max_y) do
      [next_node | get_extended_antinodes(next_node, next_node_length, max_x, max_y)]
    else
      []
    end
  end

  def is_in_matrix(_node = {x,y}, max_x, max_y) when x >= 0 and y >= 0 and x < max_x and y < max_y, do: true
  def is_in_matrix(_node, _max_x, _max_y), do: false

end
