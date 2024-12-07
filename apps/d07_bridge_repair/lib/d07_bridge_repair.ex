defmodule BridgeRepair do
  @moduledoc """
  Documentation for `BridgeRepair`.
  """

  @doc """
  Hello world.

  ## BridgeRepair

      iex> BridgeRepair.calibration_result("files/example.txt")
      3749

      iex> BridgeRepair.calibration_result("files/sample.txt")
      x

  """
  def calibration_result(path) do
    File.read!(path)
    |> String.split("\r\n")
    |> Enum.map(fn calculation -> String.split(calculation, [":", " "], trim: true) end)
    |> Enum.map(fn calculation -> Enum.map(calculation, fn number -> String.to_integer(number) end) end)
    |> Enum.filter(fn calculation -> can_be_true(calculation) end)
    |> Enum.map(fn calculation -> hd(calculation) end)
    |> Enum.sum
  end

  def can_be_true([ test_value | numbers ]) do
    possible_results = numbers
    |> possible_results
    |> List.flatten
    |> Enum.member?(test_value)
  end

  def possible_results([a, b | []]), do: [a+b, a*b]
  def possible_results([a, b | left_numbers]), do: [possible_results([a+b | left_numbers]), possible_results([a*b | left_numbers])]

end
