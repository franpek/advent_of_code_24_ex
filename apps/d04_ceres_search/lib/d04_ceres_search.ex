defmodule CeresSearch do
  @moduledoc """
  Documentation for `CeresSearch`.
  """

  @doc """
  Method to get the number of xmas in the sample.

  ## Examples

      iex> CeresSearch.xmas_count("files/example.txt")
      18

      iex> CeresSearch.xmas_count("files/sample.txt")
      2458

  """
  def xmas_count(path) do
    matrix = File.read!(path)
    |> String.split("\r\n")
    |> Enum.with_index
    |> Enum.map( fn {row, pos} -> {String.codepoints(row) |> Enum.with_index, pos} end )

    iterate_matrix(matrix, matrix, 0)
  end

  # Case last row
  defp iterate_matrix( [ {row_value, y_axis} | [] ], matrix, count ) do
    iterate_row(row_value, y_axis, matrix, count)
  end
  # Case generic row
  defp iterate_matrix( [{row_value, y_axis} | left_rows ], matrix, count) do
    iterate_matrix(left_rows, matrix, iterate_row(row_value, y_axis, matrix, count) )
  end
  # Case last letter is X
  defp iterate_row( [ {"X", x_axis} | []], y_axis, matrix, count) do
    count + return_surrounding_xmas({x_axis, y_axis}, matrix)
  end
  # Case last letter
  defp iterate_row( [ _ | []], _y_axis, _matrix, count) do
    count
  end
  # Case X letter
  defp iterate_row( [{"X", x_axis} | left_letters], y_axis, matrix, count) do
    iterate_row(left_letters, y_axis, matrix, count + return_surrounding_xmas({x_axis, y_axis}, matrix))
  end
  # Case generic letter
  defp iterate_row( [ _x_axis | left_letters], y_axis, matrix, count) do
    iterate_row(left_letters, y_axis, matrix, count)
  end

  defp return_surrounding_xmas(index, matrix) do
    xmas_letters_left = ["M","A","S"]

    [three_letters_up_left(  index, matrix), three_letters_up(  index, matrix), three_letters_up_right(  index, matrix),
     three_letters_left(     index, matrix),                                    three_letters_right(     index, matrix),
     three_letters_down_left(index, matrix), three_letters_down(index, matrix), three_letters_down_right(index, matrix)]
    |> Enum.count(fn x -> x == xmas_letters_left end)
  end

  defp three_letters_up(        {x, y}, matrix), do: [ matrix |> letter_at(x,   y-1), matrix |> letter_at(x,   y-2), matrix |> letter_at(x,   y-3) ]
  defp three_letters_up_right(  {x, y}, matrix), do: [ matrix |> letter_at(x+1, y-1), matrix |> letter_at(x+2, y-2), matrix |> letter_at(x+3, y-3) ]
  defp three_letters_right(     {x, y}, matrix), do: [ matrix |> letter_at(x+1, y),   matrix |> letter_at(x+2,   y), matrix |> letter_at(x+3,   y) ]
  defp three_letters_down_right({x, y}, matrix), do: [ matrix |> letter_at(x+1, y+1), matrix |> letter_at(x+2, y+2), matrix |> letter_at(x+3, y+3) ]
  defp three_letters_down(      {x, y}, matrix), do: [ matrix |> letter_at(x,   y+1), matrix |> letter_at(x,   y+2), matrix |> letter_at(x,   y+3) ]
  defp three_letters_down_left( {x, y}, matrix), do: [ matrix |> letter_at(x-1, y+1), matrix |> letter_at(x-2, y+2), matrix |> letter_at(x-3, y+3) ]
  defp three_letters_left(      {x, y}, matrix), do: [ matrix |> letter_at(x-1, y),   matrix |> letter_at(x-2, y  ), matrix |> letter_at(x-3, y  ) ]
  defp three_letters_up_left(   {x, y}, matrix), do: [ matrix |> letter_at(x-1, y-1), matrix |> letter_at(x-2, y-2), matrix |> letter_at(x-3, y-3) ]

  defp letter_at(_matrix, x, y) when x<0 or y<0, do: nil
  defp letter_at(matrix, x, y) do
    if Enum.count(matrix) <= y or Enum.count(matrix |> hd |> elem(0) ) <= x do
      nil
    else
      matrix |> Enum.at(y) |> elem(0) |> Enum.at(x) |> elem(0)
    end
  end

end