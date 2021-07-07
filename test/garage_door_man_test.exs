defmodule GarageDoorManTest do
  use ExUnit.Case
  doctest GarageDoorMan

  test "greets the world" do
    assert GarageDoorMan.hello() == :world
  end
end
