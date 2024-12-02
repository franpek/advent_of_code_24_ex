defmodule RedNoseReports do
  @moduledoc """
  Documentation for `RedNoseReports`.
  """

  @doc """
  Method to find the number of safe reports in the file.

  ## Examples

      iex> RedNoseReports.check_safe_reports("files/example.txt")
      2

      iex> RedNoseReports.check_safe_reports("files/sample.txt")
      472

  """
  def check_safe_reports(path) do
    File.read!(path)
    |> String.split("\r\n")
    |> Enum.map(fn report -> String.split(report, " ") end)
    |> Enum.map(fn report -> Enum.map(report, fn level -> String.to_integer(level) end) end)
    |> Enum.map(fn report -> is_safe(report) end)
    |> Enum.count(fn safe_value -> safe_value == :safe end)
  end

  defp is_safe([h1, h2 | _]) when h1 == h2, do: :unnsafe
  defp is_safe(report = [h1, h2 | _]) when h1 > h2, do: is_safe(report, :desc)
  defp is_safe(report = [h1, h2 | _]) when h1 < h2, do: is_safe(report, :asc)

  defp is_safe([h1, h2 | _], :desc) when h1 < h2, do: :unnsafe
  defp is_safe([h1, h2 | _], :asc) when h1 > h2, do: :unnsafe
  defp is_safe([h1, h2 | _], _) when abs(h1 - h2) < 1, do: :unnsafe
  defp is_safe([h1, h2 | _], _) when abs(h1 - h2) > 3, do: :unnsafe

  defp is_safe([_, _ | []], _), do: :safe
  defp is_safe([_ | tl], dir), do: is_safe(tl, dir)

  @doc """
  Method to find the number of safe reports in the file, being tolerant for one flaw.

  ## Examples

      iex> RedNoseReports.tolerant_check_safe_reports("files/example.txt")
      4

      iex> RedNoseReports.tolerant_check_safe_reports("files/sample.txt")
      502
      # Should return 520


  """

  def tolerant_check_safe_reports(path) do
    File.read!(path)
    |> String.split("\r\n")
    |> Enum.map(fn report -> String.split(report, " ") end)
    |> Enum.map(fn report -> Enum.map(report, fn level -> String.to_integer(level) end) end)
    |> Enum.map(fn report -> report_is_safe(report) end)
    |> Enum.count(fn safe_value -> safe_value == true end)
  end

  def report_is_safe(report) do
    [is_safe, is_tolerant] = report |> check_report_good_ordering

    if is_safe do
      check_report_good_levels(report, is_tolerant)
    else
      is_safe
    end
  end

  def check_report_good_ordering(report = [h1, h2 | _tl]) when h1 < h2,
    do: check_report_good_ordering(report, :asc)

  def check_report_good_ordering(report = [h1, h2 | _tl]) when h1 > h2,
    do: check_report_good_ordering(report, :desc)

  def check_report_good_ordering(report = [h1, h2, h3 | _tl]) when h1 <= h2 and h2 < h3,
    do: check_report_good_ordering(report, :asc)

  def check_report_good_ordering(report = [h1, h2, h3 | _tl]) when h1 >= h2 and h2 > h3,
    do: check_report_good_ordering(report, :desc)

  def check_report_good_ordering(report = [h1, h2, h3, h4 | _tl])
      when h1 <= h2 and h2 <= h3 and h3 < h4,
      do: check_report_good_ordering(report, :asc)

  def check_report_good_ordering(report = [h1, h2, h3, h4 | _tl])
      when h1 >= h2 and h2 >= h3 and h3 > h4,
      do: check_report_good_ordering(report, :desc)

  def check_report_good_ordering(report, order, is_tolerant \\ true)
  def check_report_good_ordering([h1, h2 | _tl], :desc, false) when h1 < h2, do: [false, nil]

  def check_report_good_ordering([h1, h2 | tl], :desc, true) when h1 < h2,
    do: check_report_good_ordering([h1 | tl], :desc, false)

  def check_report_good_ordering([h1, h2 | _tl], :asc, false) when h1 > h2, do: [false, nil]

  def check_report_good_ordering([h1, h2 | tl], :asc, true) when h1 > h2,
    do: check_report_good_ordering([h1 | tl], :asc, false)

  def check_report_good_ordering([_h1 | []], _order, is_tolerant), do: [true, is_tolerant]

  def check_report_good_ordering([_h1, h2 | tl], order, is_tolerant),
    do: check_report_good_ordering([h2 | tl], order, is_tolerant)

  def check_report_good_levels(report, is_tolerant \\ true)

  def check_report_good_levels([h1, h2 | _tl], false) when abs(h1 - h2) < 1 or abs(h1 - h2) > 3,
    do: false

  def check_report_good_levels([h1, h2 | tl], true) when abs(h1 - h2) < 1 or abs(h1 - h2) > 3,
    do: check_report_good_levels([h1 | tl], false)

  def check_report_good_levels([_h1 | []], _is_tolerant), do: true

  def check_report_good_levels([_h1, h2 | tl], is_tolerant),
    do: check_report_good_levels([h2 | tl], is_tolerant)
end
