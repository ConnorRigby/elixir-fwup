defmodule Fwup.MixProject do
  use Mix.Project

  def project do
    [
      app: :fwup,
      version: "1.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      description: description(),
      deps: deps(),
      dialyzer: [
        flags: [:missing_return, :extra_return, :unmatched_returns, :error_handling, :underspecs]
      ]
    ]
  end

  def cli do
    [
      preferred_envs: %{
        dialyzer: :test,
        docs: :docs,
        "hex.build": :docs,
        "hex.publish": :docs,
        credo: :test
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: :test, runtime: false},
      {:dialyxir, "~> 1.4", only: :test, runtime: false},
      {:ex_doc, "~> 0.19", only: :docs, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]

  defp elixirc_paths(_), do: ["lib"]

  defp description do
    "Simple Elixir wrapper around FWUP."
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/ConnorRigby/elixir-fwup",
        "fwup" => "https://github.com/fwup-home/fwup",
        "nerves" => "https://github.com/nerves-project/"
      }
    ]
  end
end
