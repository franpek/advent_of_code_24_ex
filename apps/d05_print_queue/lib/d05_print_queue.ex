defmodule PrintQueue do
  @moduledoc """
  Documentation for `PrintQueue`.
  """

  @doc """
  Method to get the sum of the middle number page of the updates correctly ordered.

  ## Examples

      iex> PrintQueue.print_middle_page_of_ordered("files/example.txt")
      143

      iex> PrintQueue.print_middle_page_of_ordered("files/sample.txt")
      6384

  """
  def print_middle_page_of_ordered(path) do
    [rules_aux, updates_aux] = File.read!(path)
    |> String.split("\r\n\r\n")
    |> Enum.map(fn x -> String.split(x, "\r\n") end)

    ordered_rules = rules_aux
    |> Enum.sort
    |> Enum.map(fn rule -> String.split(rule, "|") end)

    updates = updates_aux
    |> Enum.map(fn update -> String.split(update, ",") end)

    filter_updates_by(updates, ordered_rules, :ordered)
    |> Enum.map( fn update -> get_middle_list_element(update) end )
    |> Enum.map( fn update_page -> String.to_integer(update_page) end )
    |> Enum.sum
  end

  def get_middle_list_element(list), do: Enum.at(list, list |> length() |> div(2))

  def filter_updates_by(updates, rules, filter) do
    filter_function = case filter do
      :ordered ->  &Enum.filter/2
      :unordered -> &Enum.reject/2
    end

    updates
    |> filter_function.(fn update -> update_is_in_order_by_rules(update, rules) end)
  end

  def update_is_in_order_by_rules(_update, []), do: true
  def update_is_in_order_by_rules(update, [rule | rest_rules]) do

    update_is_in_order_by_rule = update_is_in_order_by_rule(update, rule)

      if update_is_in_order_by_rule do
        update_is_in_order_by_rules(update, rest_rules)
      else
        false
      end
  end

  def update_is_in_order_by_rule(update, _rule = [x,y]) do

    n = Enum.find_index(update, fn page -> page == x end)
    m = Enum.find_index(update, fn page -> page == y end)

    indexes_are_in_order(n ,m)
  end

  def indexes_are_in_order(n, m) when n == nil or m == nil, do: true
  def indexes_are_in_order(n, m), do: n < m

  @doc """
  Method to get the sum of the middle number page of the updates not ordered, but after sorting them

  ## Examples

      iex> PrintQueue.print_middle_page_of_fixed_unordered("files/example.txt")
      123

      iex> PrintQueue.print_middle_page_of_fixed_unordered("files/sample.txt")
      5353

  """
  def print_middle_page_of_fixed_unordered(path) do
    [rules_aux, updates_aux] = File.read!(path)
                               |> String.split("\r\n\r\n")
                               |> Enum.map(fn x -> String.split(x, "\r\n") end)

    ordered_rules = rules_aux
                    |> Enum.sort
                    |> Enum.map(fn rule -> String.split(rule, "|") end)

    updates = updates_aux
              |> Enum.map(fn update -> String.split(update, ",") end)

    filter_updates_by(updates, ordered_rules, :unordered)
    |> order_update(ordered_rules)
    |> Enum.map( fn update -> get_middle_list_element(update) end )
    |> Enum.map( fn update_page -> String.to_integer(update_page) end )
    |> Enum.sum
  end

  def order_update(updates, rules) do
    updates
    |> Enum.map( fn update -> Enum.reduce(rules, update, ( fn rule, acc -> apply_rule(acc, rule) end )) end )
  end

  def apply_rule(update, _rule = [x,y]) do

    n = Enum.find_index(update, fn page -> page == x end)
    m = Enum.find_index(update, fn page -> page == y end)

    if n != nil and m != nil and n > m do
      update |> Enum.filter(fn page -> page != x end) |> List.insert_at(m, x)
    else
      update
    end
  end

end