defmodule DynamoMigration.MixProject do
  use Mix.Project

  def project do
    [
      app: :dynamo_migration,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :hackney]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_aws_dynamo, ">= 3.0.0"},
      {:hackney, ">= 0.0.0"},
      {:jason, ">= 0.0.0"},
      {:r_enum, "~> 0.7"}
    ]
  end
end
