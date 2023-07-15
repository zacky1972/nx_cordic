defmodule NxCordic.Util do
  @moduledoc false

  @doc """
  ## Examples

      iex> NxCordic.Util.gen_input(8)
      #Nx.Tensor<
        f32[9]
        [0.0, 0.7853981852531433, 1.5707963705062866, 2.356194496154785, 3.1415927410125732, 3.9269909858703613, 4.71238899230957, 5.4977874755859375, 6.2831854820251465]
      >
  """
  def gen_input(stage) do
    0..stage
    |> Enum.map(& &1 * 1.0)
    |> Nx.tensor()
    |> Nx.divide(stage)
    |> Nx.multiply(:math.pi())
    |> Nx.multiply(2)
  end
end
