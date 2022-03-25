defmodule DynamoMigration.MixProject do
  use Mix.Project
  @source_url "https://github.com/tashirosota/dynamo_migration"
  @description "Version management tool for migration file of DynamoDB."

  def project do
    [
      app: :dynamo_migration,
      version: "0.2.0",
      elixir: "~> 1.10",
      description: @description,
      name: "DynamoMigration",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix, :eex]]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :hackney, :eex]
    ]
  end

  defp package() do
    [
      licenses: ["Apache-2.0"],
      maintainers: ["Sota Tashiro"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_aws_dynamo, ">= 3.0.0"},
      {:hackney, ">= 0.0.0"},
      {:jason, ">= 0.0.0"}
    ]
  end
end
