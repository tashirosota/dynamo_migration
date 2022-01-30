[![hex.pm version](https://img.shields.io/hexpm/v/dynamo_migration.svg)](https://hex.pm/packages/dynamo_migration)
[![CI](https://github.com/tashirosota/dynamo_migration/actions/workflows/ci.yml/badge.svg)](https://github.com/tashirosota/dynamo_migration/actions/workflows/ci.yml)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/tashirosota/dynamo_migration)

# DynamoMigration

**Simple version management tool for migration file of DynamoDB.**

## Installation

The package can be installed by adding `:dynamo_migration` to your list of dependencies in `mix.exs` along with your preferred JSON codec, HTTP client and ExAwsDynamo.

```elixir
def deps do
  [
    {:dynamo_migration, "~> 0.1.0"},
    {:ex_aws_dynamo, "~> 4.0"},
    {:jason, "~> 1.0"},
    {:hackney, "~> 1.9"}
  ]
end
```

**ExAws** uses [Jason](https://github.com/michalmuskala/jason) as its default JSON codec - if you intend to use a different codec, see [ex_aws](https://github.com/ex-aws/ex_aws) for more information about setting a custom `:json_codec`.

**See also [ExAwsDynamo](https://hexdocs.pm/ex_aws_dynamo).**

## Usage

1. Create migrations table.

   ```sh
   $ mix dynamo.setup
   ```

2. Generate and rewrite migration file.
   ```sh
   $ mix dynamo.gen.migration create_tests_table
   ```
   ```elixir
   # priv/dynamo/migrations/20220130083004_create_tests_table.exs
   defmodule Dynamo.Migrations.CreateTestsTable do
     def change do
       # Rewrite any migration code.
       # Examples.
       ExAws.Dynamo.create_table(
         "Tests",
         [id: :hash],
         %{id: :number},
         1,
         1,
         :provisioned
       )
       |> ExAws.request!()
     end
   end
   ```
3. Migrate.
   ```
   # Executes `priv/dynamo/migrations/*` if there had not migrated.
   $ mix dynamo.migrate
   ```
