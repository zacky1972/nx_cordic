inputs =
  0..3
  |> Enum.map(&(16 * 4 ** &1))
  |> Enum.map(&{"size = #{&1}", NxCordic.Util.gen_input(n: &1 + 1)})
  |> Enum.map(fn {name, input} ->
    if System.get_env("EXLA_TARGET") == "cuda" do
      {name, {input, Nx.backend_transfer(input, {EXLA.Backend, client: :cuda})}}
    else
      {name, input}
    end
  end)
  |> Map.new()

sin_jit = EXLA.jit(&Nx.sin/1)
util_cos_sin_jit = EXLA.jit(&NxCordic.Util.cos_sin/1)
cordic_cos_sin_jit = EXLA.jit(&NxCordic.cos_sin/1)

benchee =
  if System.get_env("EXLA_TARGET") == "cuda" do
    cuda_sin_jit = EXLA.jit(&Nx.sin/1, client: :cuda)
    cuda_until_cos_sin_jit = EXLA.jit(&NxCordic.Util.cos_sin/1, client: :cuda)
    cuda_cordic_cos_sin_jit = EXLA.jit(&NxCordic.cos_sin/1, client: :cuda)

    %{
      "Nx sin" => fn {input, _} -> Nx.sin(input) end,
      "EXLA CPU sin" => fn {input, _} -> sin_jit.(input) end,
      "EXLA GPU sin" => {fn {_, input} -> cuda_sin_jit.(input) end, after_each: &Nx.backend_deallocate/1},
      "Nx cos_sin" => fn {input, _} -> NxCordic.Util.cos_sin(input) end,
      "EXLA CPU cos_sin" => fn {input, _} -> util_cos_sin_jit.(input) end,
      "EXLA GPU cos_sin" => {fn {_, input} -> cuda_until_cos_sin_jit.(input) end, after_each: &Nx.backend_deallocate/1},
      "Nx CORDIC" => fn {input, _} -> NxCordic.cos_sin(input) end,
      "EXLA CPU CORDIC" => fn {input, _} -> cordic_cos_sin_jit.(input) end,
      "EXLA GPU CORDIC" => {fn {_, input} -> cuda_cordic_cos_sin_jit.(input) end, after_each: &Nx.backend_deallocate/1}
    }
  else
    %{
      "Nx sin" => fn input -> Nx.sin(input) end,
      "EXLA sin" => fn input -> sin_jit.(input) end,
      "Nx cos_sin" => fn input -> NxCordic.Util.cos_sin(input) end,
      "EXLA cos_sin" => fn input -> util_cos_sin_jit.(input) end,
      "Nx CORDIC" => fn input -> NxCordic.cos_sin(input) end,
      "EXLA CORDIC" => fn input -> cordic_cos_sin_jit.(input) end
    }
  end

Benchee.run(
  benchee,
  inputs: inputs
)
