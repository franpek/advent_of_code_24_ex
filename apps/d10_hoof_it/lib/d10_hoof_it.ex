defmodule HoofIt do
  @moduledoc """
  Documentation for `HoofIt`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> HoofIt.trailheads_in_map("files/example.txt")
      37 (Should be 36)

      iex> HoofIt.trailheads_in_map("files/sample.txt")
      650 (Should be less)

  """
  def trailheads_in_map(path) do
    matrix = File.read!(path)
      |> format_matrix

    starting_positions = find_starts(matrix)

    trail = trail(matrix, starting_positions)

    total_score = trail |> IO.inspect |> Enum.map( fn trail -> Enum.count(trail) end) |> Enum.sum
  end

  def trail(matrix, positions, result \\ [])

  def trail(matrix, [], result) do
    result
  end

  def trail(matrix, [position | rest_positions], result) do
    trail(matrix, rest_positions, [
      trail_position(matrix, position) |> List.flatten() |> Enum.uniq() | result
    ])
  end

  def trail_position(matrix, position, result \\ [])

  def trail_position(_matrix, position = {9, _}, result) do
    position
  end

  def trail_position(matrix, position, result) do
    surrounding_next_scores = find_surrounding_next_scores(matrix, position)

    if surrounding_next_scores != [] do
      surrounding_next_scores
      |> Enum.map(fn new_pos -> trail_position(matrix, new_pos, result) end)
    else
      []
    end
  end

  defp find_surrounding_next_scores(matrix, {score, {x, y}}) do
    up = find_at(matrix, {x, y - 1})
    left = find_at(matrix, {x - 1, y})
    down = find_at(matrix, {x, y + 1})
    right = find_at(matrix, {x + 1, y})

    [up, left, down, right]
    |> Enum.filter(fn position -> position != nil and elem(position, 0) - 1 == score end)
  end

  defp find_at(matrix, {x, y}),
    do:
      matrix
      |> Enum.at(y)
      |> (fn row ->
            if row != nil do
              Enum.at(row, x)
            else
              nil
            end
          end).()

  defp find_starts(matrix) do
    matrix
    |> List.flatten()
    |> Enum.filter(fn {score, _} -> score == 0 end)
  end

  defp format_matrix(input) do
    input
    |> String.split("\r\n")
    |> Enum.with_index()
    |> Enum.map(fn {row, y} -> format_matrix_row(row, y) end)
  end

  def format_matrix_row(row, y) do
    row
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {score, x} -> {String.to_integer(score), {x, y}} end)
  end
end
