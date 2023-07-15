defmodule NxCordic.MixProject do
  use Mix.Project

  def project do
    [
      app: :nx_cordic,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nx, "~> 0.5"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end
end