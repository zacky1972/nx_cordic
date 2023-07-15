defmodule NxCordic.Util do
  @moduledoc false

  import Nx.Defn

  @doc """
  ## Examples

      iex> NxCordic.Util.gen_input(8)
      #Nx.Tensor<
        f32[9]
        [0.0, 0.7853981852531433, 1.5707963705062866, 2.356194496154785, 3.1415927410125732, 3.9269909858703613, 4.71238899230957, 5.4977874755859375, 6.2831854820251465]
      >
  """
  def gen_input(stage) do
    Nx.linspace(0, 1, n: stage + 1)
    |> Nx.multiply(:math.pi())
    |> Nx.multiply(2)
  end

  defn cos_sin(angles) do
    {Nx.cos(angles), Nx.sin(angles)}
  end

  defn equals_with_epsilon(t1, t2, epsilon) do
    Nx.subtract(t1, t2)
    |> Nx.abs()
    |> Nx.less_equal(epsilon)
    |> Nx.all()
  end

  defn equals_tuple_with_epsilon({t1_1, t1_2}, {t2_1, t2_2}, epsilon) do
    Nx.concatenate([equals_with_epsilon(t1_1, t2_1, epsilon), equals_with_epsilon(t1_2, t2_2, epsilon)])
    |> Nx.all()
  end
end
