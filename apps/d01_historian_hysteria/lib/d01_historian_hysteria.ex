defmodule HistorianHysteria do
  @moduledoc """
  Documentation for `HistorianHysteria`.
  """

  @doc """
  Method to find the total distance between the left list and the right list,
  from the notes and lists of historically significant locations

  ## Examples

      iex> HistorianHysteria.distance("files/example.txt")
      11

      iex> HistorianHysteria.distance("files/sample.txt")
      1258579

  """
  def distance (path) do
    File.read!(path)
    |> String.split(["\r\n", "   "])
    |> Enum.map( fn char -> String.to_integer(char) end)
    |> (fn int_list -> split_in_two(int_list) end).()
    |> Enum.map( fn split_list -> Enum.sort(split_list) end)
    |> (fn [left, right] -> Enum.zip(left, right) end).()
    |> Enum.map( fn {x, y} -> abs(x-y) end)
    |> Enum.sum
  end

  defp split_in_two(list), do: split_in_two(list, [], [])
  defp split_in_two([l, r | tl], [], []), do: split_in_two( tl, [l], [r])
  defp split_in_two([l, r | []], left, right), do: [[l | left], [r | right]]
  defp split_in_two([l, r | tl], left, right), do: split_in_two( tl, [l | left], [r | right])

  @doc """
  Method to find the similarity score between the element of the left list and the right list.

  ## Examples

      iex> HistorianHysteria.similarity("files/example.txt")
      31

      iex> HistorianHysteria.similarity("files/sample.txt")
      23981443

  """

  def similarity (path) do
    File.read!(path)
    |> String.split(["\r\n", "   "])
    |> Enum.map( fn char -> String.to_integer(char) end)
    |> (fn int_list -> split_in_two(int_list) end).()
    |> similarity_formula
    |> Enum.sum
  end

  def similarity_formula([left, right]), do: left |> Enum.map(fn l -> l * Enum.count(right, fn r -> l == r end) end)

end