defmodule NxCordicTest do
  use ExUnit.Case
  doctest NxCordic

  test "cos_sin" do
    input = NxCordic.Util.gen_input(256)

    assert NxCordic.Util.equals_tuple_with_epsilon(NxCordic.cos_sin(input), NxCordic.Util.cos_sin(input), 0.0001) |> Nx.to_number() == 1
  end
end
