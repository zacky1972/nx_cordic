defmodule NxCordic do
  @moduledoc File.read!("README.md")
             |> String.split("<!-- MODULEDOC -->")
             |> Enum.fetch!(1)

  import Nx.Defn

  @bit_size 32
  @max Bitwise.bsl(1, @bit_size - 1)

  @k_value 0..31
           |> Enum.map(&(2 ** (-2 * &1)))
           |> Enum.map(&:math.sqrt(1 + &1))
           |> Enum.map(&(1.0 / &1))
           |> Enum.reduce(fn x, acc -> x * acc end)
           |> Kernel.*(@max)
           |> floor()

  @angles 0..31
          |> Enum.map(&(2 ** -&1))
          |> Enum.map(&:math.atan/1)
          |> Enum.map(&(&1 / :math.pi()))
          |> Enum.map(&(&1 * @max))
          |> Enum.map(&floor(&1))
          |> Enum.reject(&(&1 == 0))
          |> List.to_tuple()

  @pi Nx.Constants.pi()
  @double_pi Nx.multiply(2.0, @pi)
  @factor_angle_to_fixed_point Nx.divide(@max, @pi)

  @half_pi_fixed_point Bitwise.bsr(@max, 1)

  defnp regularize(theta) do
    theta - Nx.floor(theta / @double_pi) * @double_pi
  end

  defnp angle_to_fixed_point(theta) do
    Nx.as_type(regularize(theta) * @factor_angle_to_fixed_point, {:s, 32})
  end

  defn cos_sin(theta) do
    theta_i = angle_to_fixed_point(theta)
    c1 = Nx.less(theta_i, -@half_pi_fixed_point)
    c3 = Nx.greater(theta_i, @half_pi_fixed_point)
    nc2 = Nx.logical_or(c1, c3)
    c2 = Nx.logical_not(nc2)
    s = (Nx.as_type(nc2, {:s, 32}) |> Nx.negate()) + Nx.as_type(c2, {:s, 32})
    theta_i = (theta_i + @max) * c1 + theta_i * c2 + (theta_i - @max) * c3
    {vcos, vsin} = cordic_cos_sin(theta_i)
    {s * vcos, s * vsin}
  end

  defnp cordic_cos_sin(theta_i) do
    {vcos, vsin} = {Nx.broadcast(@k_value, theta_i), Nx.broadcast(0, theta_i)}

    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 0

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 1

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 2

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 3

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 4

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 5

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 6

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 7

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 8

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 9

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 10

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 11

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 12

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 13

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 14

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 15

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 16

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 17

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 18

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 19

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 20

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 21

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 22

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 23

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 24

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 25

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 26

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 27

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 28

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 29

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    theta_i = theta_i + elem(@angles, j) * c_neg - elem(@angles, j) * c_non_neg
    c_neg = Nx.less(theta_i, 0)
    c_non_neg = Nx.greater_equal(theta_i, 0)

    j = 30

    {vcos, vsin} =
      {
        vcos + Nx.right_shift(vsin * c_neg - vsin * c_non_neg, j),
        vsin + Nx.right_shift(vcos * c_non_neg - vcos * c_neg, j)
      }

    {Nx.as_type(vcos, {:f, 32}) / @max, Nx.as_type(vsin, {:f, 32}) / @max}
  end
end
