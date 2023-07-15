inputs =
  0..3
  |> Enum.map(&(16 * 4 ** &1))
  |> Enum.map(&{"size = #{&1}", NxCordic.Util.gen_input(&1)})
  |> Map.new()

sin_jit = EXLA.jit(&Nx.sin/1)
util_cos_sin_jit = EXLA.jit(&NxCordic.Util.cos_sin/1)
cordic_cos_sin_jit = EXLA.jit(&NxCordic.cos_sin/1)

Benchee.run(
  %{
    "Nx sin" => fn input -> Nx.sin(input) end,
    "EXLA sin" => fn input -> sin_jit.(input) end,
    "Nx cos_sin" => fn input -> NxCordic.Util.cos_sin(input) end,
    "EXLA cos_sin" => fn input -> util_cos_sin_jit.(input) end,
    "Nx CORDIC" => fn input -> NxCordic.cos_sin(input) end,
    "EXLA CORDIC" => fn input -> cordic_cos_sin_jit.(input) end
  },
  inputs: inputs
)
