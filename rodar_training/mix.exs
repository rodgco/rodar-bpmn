defmodule RodarTraining.MixProject do
  use Mix.Project

  def project do
    [
      app: :rodar_training,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {RodarTraining.Application, []}
    ]
  end

  defp deps do
    [
      {:rodar, "~> 1.4"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "deps.compile", "compile"]
    ]
  end
end
