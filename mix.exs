defmodule Playground.MixProject do
  use Mix.Project

  def project do
    [
      app: :playground,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      applications: [:logger, :ecto],
      mod: {Playground.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.0.1"},
      {:jason, "~> 1.1"},
      {:stream_data, "~> 0.1"}
    ]
  end
end
