defmodule MullItOver do
  @moduledoc """
  Documentation for `MullItOver`.
  """

  @doc """
  Method to get and sum the multiplications in the sample.

  ## Examples

      iex> MullItOver.recover_memory("files/example1.txt")
      161

      iex> MullItOver.recover_memory("files/sample.txt")
      185797128

  """
  def recover_memory(path) do
    File.read!(path)
    |> String.codepoints()
    |> parse_and_append
    |> decrypt
  end

  def parse_and_append(origin, result_list \\ [])
  def parse_and_append([], result_list), do: result_list |> Enum.reverse()

  def parse_and_append([hd | tl], result_list = [previous_elem | result_list_tl]) do
    parsed = hd |> Integer.parse()

    if parsed == :error do
      parse_and_append(tl, [hd | result_list])
    else
      if is_integer(previous_elem) do
        appended_elem = (Integer.to_string(previous_elem) <> hd) |> String.to_integer()
        parse_and_append(tl, [appended_elem | result_list_tl])
      else
        parse_and_append(tl, [elem(parsed, 0) | result_list])
      end
    end
  end

  def parse_and_append([hd | tl], result_list) do
    parsed = hd |> Integer.parse()

    if parsed == :error do
      parse_and_append(tl, [hd | result_list])
    else
      parse_and_append(tl, [elem(parsed, 0) | result_list])
    end
  end

  def decrypt(list, result \\ 0)
  def decrypt([], result), do: result

  def decrypt(["m", "u", "l", "(", n1, ",", n2, ")" | tl], result),
    do: decrypt(tl, n1 * n2 + result)

  def decrypt([_hd | tl], result), do: decrypt(tl, result)

  @doc """
  Method to find the number of safe reports in the file, being tolerant for one flaw.

  ## Examples

      iex> MullItOver.recover_memory_with_mode("files/example2.txt")
      48

      iex> MullItOver.recover_memory_with_mode("files/sample.txt")
      89798695

  """

  def recover_memory_with_mode(path) do
    File.read!(path)
    |> String.codepoints()
    |> parse_and_append
    |> decrypt_with_mode
  end

  def decrypt_with_mode(list, result \\ 0, enabled \\ true)
  def decrypt_with_mode([], result, _enabled), do: result
  def decrypt_with_mode(["d", "o", "(", ")" | tl], result, _enabled), do: decrypt_with_mode(tl, result, true)

  def decrypt_with_mode(["d", "o", "n", "'", "t", "(", ")" | tl], result, _enabled),
      do: decrypt_with_mode(tl, result, false)

  def decrypt_with_mode(["m", "u", "l", "(", n1, ",", n2, ")" | tl], result, true), do: decrypt_with_mode(tl, n1 * n2 + result, true)

  def decrypt_with_mode([_hd | tl], result, enabled), do: decrypt_with_mode(tl, result, enabled)

end
