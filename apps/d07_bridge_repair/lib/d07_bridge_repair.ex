defmodule BridgeRepair do
  @moduledoc """
  Documentation for `BridgeRepair`.
  """

  @doc """
  Returns the sum of the truthy calculation's test value, with operators + and *.

  ## BridgeRepair

      iex> BridgeRepair.calibration_result("files/example.txt")
      3749

      iex> BridgeRepair.calibration_result("files/sample.txt")
      20281182715321

  """
  def calibration_result(path, with_concatenation \\ false) do
    File.read!(path)
    |> String.split("\r\n")
    |> Enum.map(fn calculation -> String.split(calculation, [":", " "], trim: true) end)
    |> Enum.map(fn calculation -> Enum.map(calculation, fn number -> String.to_integer(number) end) end)
    |> Enum.filter(fn calculation -> can_be_true(calculation, with_concatenation) end)
    |> Enum.map(fn calculation -> hd(calculation) end)
    |> Enum.sum
  end

  def can_be_true([ test_value | numbers ], with_concatenation) do
    numbers
    |> possible_results(with_concatenation)
    |> List.flatten
    |> Enum.member?(test_value)
  end

  def possible_results([a, b | []], false), do: [a+b, a*b]
  def possible_results([a, b | []], true), do: [a+b, a*b, concatenation(a,b) ]
  def possible_results([a, b | left_numbers], false) do
    [
      possible_results([a+b | left_numbers], false),
      possible_results([a*b | left_numbers], false)
    ]
  end
  def possible_results([a, b | left_numbers], true) do
    [
      possible_results([a+b | left_numbers], true),
      possible_results([a*b | left_numbers], true),
      possible_results([concatenation(a,b) | left_numbers], true),
    ]
  end

  @doc """
  Returns the sum of the truthy calculation's test value, with operators +, * and ||.

  ## BridgeRepair

      iex> BridgeRepair.calibration_result("files/example.txt", true)
      11387

      iex> BridgeRepair.calibration_result("files/sample.txt", true)
      159490400628354

  """
  def concatenation(a, b), do:  String.to_integer(Integer.to_string(a) <> Integer.to_string(b))

end
