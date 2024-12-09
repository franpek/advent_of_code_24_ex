defmodule DiskFragmenter do
  @moduledoc """
  Documentation for `DiskFragmenter`.
  """

  @doc """
  Hello world.

  ## DiskFragmenter

      iex> DiskFragmenter.get_checksum("files/example.txt")
      1928

      iex> DiskFragmenter.get_checksum("files/sample.txt")
      6310675819476

  """
  def get_checksum(path) do
    list =
      File.read!(path)
      |> String.graphemes()
      |> Enum.map(fn char -> String.to_integer(char) end)
      |> Enum.with_index()
      |> deglose_block
      |> List.flatten()
      |> Enum.with_index()

    inverse_list = list |> Enum.filter(fn item -> item != "." end) |> Enum.reverse()

    fill_empty_spaces(list, inverse_list)
    |> Enum.map(fn {x, y} -> x end)
    |> Enum.with_index()
    |> Enum.map(fn {x, y} -> x * y end)
    |> Enum.sum()
  end

  def fill_empty_spaces(ordered_list, inversed_list, result \\ [])

  def fill_empty_spaces(ol, il, result) when il == [] or ol == [],
    do: result |> Enum.reverse() |> Enum.uniq()

  def fill_empty_spaces(ol = [{".", _} | _], _ = [{".", _} | rest_il], result),
    do: fill_empty_spaces(ol, rest_il, result)

  def fill_empty_spaces([{".", _} | rest_ol], il = [h2 | rest_il], result),
    do: fill_empty_spaces(rest_ol, rest_il, [h2 | result])

  def fill_empty_spaces([h1 | rest_ol], il, result),
    do: fill_empty_spaces(rest_ol, il, [h1 | result])

  def deglose_block(list, result \\ [])
  def deglose_block([], result), do: result |> Enum.reverse()

  def deglose_block([{x, pos} | tail], result),
    do: deglose_block(tail, [deglose(x, pos) | result])

  def deglose(value, index, result \\ [])
  def deglose(0, index, result), do: result

  def deglose(value, index, result),
    do: deglose(value - 1, index, [digit_or_space_value(index) | result])

  def digit_or_space_value(index) do
    if even(index) do
      trunc(index / 2)
    else
      "."
    end
  end

  def even(int), do: int >= 0 and rem(int, 2) == 0
end
