<!-- @format -->

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

### 1. Creates migrations table.

First of all, you need to create a migration table for version management.
Type this in your console.

```sh
$ mix dynamo.setup
```

### 2. Generates and rewrite migration file.

Then create a file for management and add your changes.

```sh
$ mix dynamo.gen.migration create_tests_table --table tests -e
```

```elixir
# priv/dynamo/migrations/20220130083004_create_tests_table.exs
defmodule Dynamo.Migrations.CreateTestsTable do
  @table_name "#{Mix.env()}.test"
  def table_name, do: @table_name
  def change do
    # Rewrite any changes.
    # Examples.
    ExAws.Dynamo.create_table(
      "Tests",
      [id: :hash],
      %{id: :number},
      1,Create migrations tabl
      1,
      :provisioned
    )
    |> ExAws.request!()
  end
end
```

### 3. Migrates.

You can run the migration file.
And it's managed by a version table so it won't be duplicated.
It is also useful as an operation history for DynamoDB.

```bash
# Executes `priv/dynamo/migrations/*` if there had not migrated.
$ mix dynamo.migrate
```

### 4. Resets.

In a test environment, you would like to reset migration every time I run it.
You can use `mix dynamo.reset`.

## Command options

### mix dynamo.gen.migration

| option       | alias | type    | effect                                               |
| ------------ | ----- | ------- | ---------------------------------------------------- |
| --table      | -t    | string  | table name for management ★ Required.                |
| --env_prefix | -e    | boolean | Mix.env () is added to the prefix of the table name. |

### mix dynamo.reset

| option       | alias | type    | effect                                                                                                                                    |
| ------------ | ----- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| --prefix     | -p    | string  | Executes only for table changes that include the specified prefix.                                                                        |
| --env_prefix | -e    | boolean | Execute only for tables to which Mix.env () is applied as prefix.</br>It is recommended to use the -e option of `gen.migration` together. |

## Bugs and Feature requests

Feel free to open an issues or a PR to contribute to the project.
