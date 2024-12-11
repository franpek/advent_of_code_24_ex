defmodule PlutonianPebbles do
  @moduledoc """
  Documentation for `PlutonianPebbles`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> PlutonianPebbles.blink("files/example.txt", 6)
      22

      iex> PlutonianPebbles.blink("files/sample.txt", 25)
      233875

  """
  def blink(path, times) do
    File.read!(path)
    |> String.split(" ")
    |> Enum.map(fn stone -> blink_times(stone, times) end)
    |> List.flatten
    |> Enum.count

  end

  def blink_times(stone, times \\ 1)
  def blink_times(stone, 0), do: stone
  def blink_times("0", times), do: blink_times("1", times-1)
  def blink_times(stone, times) do
    number_of_digits = stone |> String.graphemes |> Enum.count
    even_digits = number_of_digits |> even
    left_times = times-1

    if even_digits do
      {left_stone, right_stone} = String.split_at(stone, trunc(number_of_digits / 2))
      [blink_times(left_stone, left_times), blink_times(quit_leading_zeros(right_stone), left_times)] |> List.flatten
    else
      new_stone =  String.to_integer(stone) * 2024 |> Integer.to_string
      blink_times(new_stone, left_times)
    end
  end

  def even(int), do: int >= 0 and rem(int, 2) == 0

  def quit_leading_zeros(number) do
    number
    |> String.graphemes()
    |> drop_leading_zeroes()
    |> Enum.join
  end

  defp drop_leading_zeroes(["0" | []]), do: ["0"]
  defp drop_leading_zeroes(["0" | rest]), do: drop_leading_zeroes(rest)
  defp drop_leading_zeroes(non_zero), do: non_zero

end
