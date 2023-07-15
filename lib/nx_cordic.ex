defmodule NxCordic do
  @moduledoc File.read!("README.md")
             |> String.split("<!-- MODULEDOC -->")
             |> Enum.fetch!(1)

  import Nx.Defn

  defn cos_sin(angles) do
    {Nx.cos(angles), Nx.sin(angles)}
  end
end
