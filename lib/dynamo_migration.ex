defmodule DynamoMigration do
  @moduledoc """
  Version management module for migration file of DynamoDB.
  Dependes on ExAws and ExAws.Dynamo.
  See also https://github.com/ex-aws/ex_aws_dynamo.
  Usage:
    1. $ mix dynamo.setup # Creates migrations table.
    2. $ mix dynamo.gen.migration create_tests_table # Generates migration file.
    ```elixir
    defmodule Dynamo.Migrations.CreateTestsTable do
      def change do
        # Rewrite any migration code.
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
    3. $ mix dynamo.migrate # Migrates `priv/dynamo/migrations/*`.
  """
  require Logger
  alias ExAws.Dynamo
  @table "Migrations"
  @migration_file_path "priv/dynamo/migrations"
  @doc """
  Called from `mix dynamo.migrate`
  Executes migration files if there had not migrated.
  """
  @spec migrate :: :ok
  def migrate do
    migration_files!()
    |> compile_migrations()
    |> REnum.each(fn {mod, version} ->
      if migration_required?(version) do
        mod.change()
        insert_migration_version(version)
        Logger.debug("Migrate #{mod} was succeed")
      end
    end)
  end

  @doc """
  Returns true if migration version does not exists in migrations table.
  """
  @spec migration_required?(integer()) :: boolean
  def migration_required?(version) do
    result =
      Dynamo.query(
        @table,
        limit: 1,
        expression_attribute_values: [version: version],
        key_condition_expression: "version = :version"
      )
      |> ExAws.request!()

    RMap.get(result, "Count") == 0
  end

  @doc """
  Creates migrations table for version management.
  Called from `mix dynamo.setup`
  """
  @spec setup :: :ok
  def setup do
    tables = Dynamo.list_tables() |> ExAws.request!() |> RMap.get("TableNames")

    if @table in tables do
      Logger.debug("Migrations table was already created.")
    else
      Dynamo.create_table(
        @table,
        [version: :hash],
        [version: :number],
        1,
        1,
        :provisioned
      )
      |> ExAws.request!()

      Logger.debug("Migrations table was created.")
    end

    :ok
  end

  @spec migration_file_path :: String.t()
  def migration_file_path do
    @migration_file_path
  end

  defp insert_migration_version(version) do
    Dynamo.put_item(
      @table,
      %{version: version}
    )
    |> ExAws.request!()
  end

  defp migration_files!() do
    case File.ls(migration_file_path()) do
      {:ok, files} -> files
      {:error, _} -> raise "test"
    end
  end

  defp compile_migrations(files) do
    files
    |> Enum.map(fn file ->
      mod =
        (migration_file_path() <> "/" <> file)
        |> Code.compile_file()
        |> REnum.map(&elem(&1, 0))
        |> REnum.first()

      version =
        Regex.scan(~r/[0-9]/, file)
        |> REnum.join()
        |> String.to_integer()

      {mod, version}
    end)
  end
end
