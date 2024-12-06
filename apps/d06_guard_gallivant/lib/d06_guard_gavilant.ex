defmodule GuardGavilant do
  @moduledoc """
  Documentation for `GuardGavilant`.
  """

  @doc """
  Count the number of different positions the guard go through.

  ## GuardGavilant

      iex> GuardGavilant.different_position_in_round("files/example.txt")
      41

      iex> GuardGavilant.different_position_in_round("files/example2.txt")
      17

      iex> GuardGavilant.different_position_in_round("files/sample.txt")
      5318

  """
  def different_position_in_round(path) do
    matrix = File.read!(path)
    |> String.split("\r\n")
    |> Enum.with_index
    |> Enum.map( fn {row, pos} -> {String.codepoints(row) |> Enum.with_index, pos} end )

    starting_position = matrix
    |> find_value_in_matrix("^")

    traverse(matrix, starting_position)
    |> Enum.uniq
    |> Enum.count
  end

  def find_value_in_matrix(matrix, value) do
    matrix
    |> Enum.find_value(fn {row, y} -> find_value_in_row(row, value, y) end)
  end

  def find_value_in_row(row, value, y) do
    row
    |> Enum.find_value(fn {element, x} -> if element == value, do: {x, y} end)
  end

  def traverse(matrix, position, direction \\ :up, route \\ [])
  def traverse(matrix, position, direction, route) do
    next_position = next_position(position, direction)
    next_element = next_position |> (fn next_position -> element_at_matrix(matrix, next_position) end).()

    case next_element do
      nil -> [position | route]
      {"#", _} -> traverse(matrix, position, next_direction(direction), [position | route])
      _ -> traverse(matrix, next_position, direction, [position | route])
    end
  end

  def next_position(pos, direction)
  def next_position(_pos = {x,y}, :up),    do: {  x,y-1}
  def next_position(_pos = {x,y}, :right), do: {x+1,  y}
  def next_position(_pos = {x,y}, :down),  do: {  x,y+1}
  def next_position(_pos = {x,y}, :left),  do: {x-1,  y}

  def element_at_matrix(_matrix, _pos = {x,y}) when x<0 or y<0, do: nil
    def element_at_matrix(matrix, _pos = {x,y}) do
    row = matrix |> Enum.at(y)

    if row != nil do
      row |> elem(0) |> Enum.at(x)
    end
  end

  def next_direction(direction)
  def next_direction(:up), do: :right
  def next_direction(:right), do: :down
  def next_direction(:down), do: :left
  def next_direction(:left), do: :up

end
