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
  def different_positions_in_round(path) do
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

  @doc """
  Count the number of possible positions for loop-obstruction.

  ## GuardGavilant

      iex> GuardGavilant.possible_loop_obstruction_positions("files/example.txt")
      6

      iex> GuardGavilant.possible_loop_obstruction_positions("files/example2.txt")
      x

      iex> GuardGavilant.possible_loop_obstruction_positions("files/sample.txt")
      104 WRONG

  """
  def possible_loop_obstruction_positions(path) do
    matrix = File.read!(path)
             |> String.split("\r\n")
             |> Enum.with_index
             |> Enum.map( fn {row, pos} -> {String.codepoints(row) |> Enum.with_index, pos} end )

    starting_position = matrix
                        |> find_value_in_matrix("^")

    boxes_it_hits = traverse_for_loop(matrix, starting_position) |> Enum.reverse

    loop_boxes = boxes_it_hits |> get_loop_boxes_positions  |> Enum.count

  end

  def traverse_for_loop(matrix, position, direction \\ :up, box_positions \\ [])
  def traverse_for_loop(matrix, position, direction, box_positions) do
    next_position = next_position(position, direction)
    next_element = next_position |> (fn next_position -> element_at_matrix(matrix, next_position) end).()

    case next_element do
      nil -> box_positions
      {"#", _} -> traverse_for_loop(matrix, position, next_direction(direction), [next_position | box_positions])
      _ -> traverse_for_loop(matrix, next_position, direction, box_positions)
    end
  end

  def get_loop_boxes_positions( box_positions = [_h1, _h2, _h3 | []]), do: [get_loop_box_position(box_positions) |> elem(0)]
  def get_loop_boxes_positions( box_positions = [h1, h2, h3, h4 | left_boxes]) do

    {loop_box, dir} = get_loop_box_position(box_positions)

    if loop_box != nil and is_before(loop_box, h4, dir) do
      [loop_box | get_loop_boxes_positions([h2, h3, h4 | left_boxes])]
    else
      get_loop_boxes_positions([h2, h3, h4 | left_boxes])
    end
 end

  def get_loop_box_position(box_positions)
  def get_loop_box_position([{x1,y1}, {x2,y2}, {x3,y3} | _rest]) when x1 < x2 and y2 < y3, do: {{x1-1, y3-1}, :left}
  def get_loop_box_position([{x1,y1}, {x2,y2}, {x3,y3} | _rest]) when y1 < y2 and x2 < x3, do: {{x3+1, y1-1}, :up}
  def get_loop_box_position([{x1,y1}, {x2,y2}, {x3,y3} | _rest]) when x1 < x2 and y2 > y3, do: {{x1+1, y3+1}, :right}
  def get_loop_box_position([{x1,y1}, {x2,y2}, {x3,y3} | _rest]) when y1 > y2 and x2 < x3, do: {{x3-1, y1+1}, :down}
  def get_loop_box_position(_box_positions), do: {:nil, :nil}

  def is_before({x1,y1}, {x2,y2}, :left ) when y1 == y2, do: x1 > x2
  def is_before({x1,y1}, {x2,y2}, :right) when y1 == y2, do: x1 < x2
  def is_before({x1,y1}, {x2,y2}, :up   ) when x1 == x2, do: y1 > y2
  def is_before({x1,y1}, {x2,y2}, :down ) when x1 == x2, do: y1 < y2
  def is_before(_, _, _), do: true

end
