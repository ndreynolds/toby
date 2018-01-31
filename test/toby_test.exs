defmodule TobyTest do
  use ExUnit.Case
  doctest Toby

  test "greets the world" do
    assert Toby.hello() == :world
  end
end
