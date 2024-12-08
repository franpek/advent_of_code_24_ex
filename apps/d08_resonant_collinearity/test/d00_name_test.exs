defmodule D00NameTest do
  use ExUnit.Case
  doctest D00Name

  test "greets the world" do
    assert D00Name.hello() == :world
  end
end
