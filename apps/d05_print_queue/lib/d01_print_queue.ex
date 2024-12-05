defmodule PrintQueue do
  @moduledoc """
  Documentation for `PrintQueue`.
  """

  @doc """
  Method to get the number of xmas in the sample.

  ## Examples

      iex> PrintQueue.print_middle_page("files/example.txt")
      143

      iex> PrintQueue.print_middle_page("files/sample.txt")
      6384

  """
  def print_middle_page(path) do
    [rules_aux, updates_aux] = File.read!(path)
    |> String.split("\r\n\r\n")
    |> Enum.map(fn x -> String.split(x, "\r\n") end)

    rules = rules_aux
    |> Enum.map(fn rule -> String.split(rule, "|") end)

    updates = updates_aux
    |> Enum.map(fn update -> String.split(update, ",") end)

    filter_correct_updates(updates, rules)
    |> Enum.map( fn update -> Enum.at(update, update |> length() |> div(2)) end )
    |> Enum.map( fn update_page -> String.to_integer(update_page) end )
    |> Enum.sum
  end

  def filter_correct_updates(updates, rules) do
    Enum.map(updates, fn update_page -> iterate_rules(update_page, rules) end)
    |> Enum.filter( fn x -> x != nil end)
  end

  def iterate_rules(update_page, rules) do
    is_in_order = Enum.map(rules, fn rule -> is_in_order(update_page, rule) end)
    |> Enum.uniq()
    |> (fn x -> x == [true] end).()

    if is_in_order do
      update_page
    else
      nil
    end
  end

  def is_in_order(update, [x,y]) do

    n = Enum.find_index(update, fn update_page -> update_page == x end)
    m = Enum.find_index(update, fn update_page -> update_page == y end)

    is_in_order_n_m(n ,m)
  end

  def is_in_order_n_m(n, m) when n == nil or m == nil, do: true
  def is_in_order_n_m(n, m), do: n < m

end
