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
  @table "migrations"
  @migration_file_path "priv/dynamo/migrations"

  @doc false
  @spec migration_file_path :: String.t()
  def migration_file_path, do: @migration_file_path

  @doc """
  Called from `mix dynamo.migrate`
  Executes migration files if there had not migrated.
  """
  @spec migrate :: :ok
  def migrate do
    case File.ls(migration_file_path()) do
      {:ok, files} ->
        files
        |> compile_migrations()
        |> Enum.filter(fn {_, version} -> migration_required?(version) end)
        |> Enum.each(fn {mod, version} ->
          mod.change()
          insert_migration_version(mod.table_name(), version)
          Logger.debug("Migrate #{mod} was succeed")
        end)

      error ->
        error
    end
  end

  @doc """
  Creates migrations table for version management.
  Called from `mix dynamo.setup`
  """
  @spec setup :: :ok
  def setup do
    if @table in table_names() do
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
  end

  @doc """
  Reset table migrations.
  """
  def reset(only_prefix \\ nil) do
    current_versions = versions()

    table_names()
    |> Enum.reject(&(&1 == @table))
    |> Enum.filter(fn table_name ->
      unless only_prefix do
        true
      else
        table_name =~ Regex.compile!("\A#{table_name}")
      end
    end)
    |> Enum.each(&delete_table(&1, current_versions))

    migrate()
  end

  @doc false
  @spec migration_required?(binary()) :: boolean
  def migration_required?(version) do
    Dynamo.get_item(@table, %{version: version})
    |> ExAws.request!()
    |> (fn result -> result == %{} end).()
  end

  defp versions() do
    Dynamo.scan(@table)
    |> ExAws.request!()
    |> Map.get("Items", [])
    |> Enum.map(fn version ->
      %{
        version: version["version"]["N"] |> String.to_integer(),
        table_name: version["table_name"]["S"]
      }
    end)
  end

  defp insert_migration_version(table_name, version) do
    Dynamo.put_item(
      @table,
      %{table_name: table_name, version: version}
    )
    |> ExAws.request!()
  end

  defp compile_migrations(files) do
    files
    |> Enum.map(fn file ->
      [mod | _] =
        (migration_file_path() <> "/" <> file)
        |> Code.compile_file()
        |> Enum.map(&elem(&1, 0))

      version =
        Regex.scan(~r/[0-9]/, file)
        |> Enum.join()
        |> String.to_integer()

      {mod, version}
    end)
  end

  defp delete_table(table_name, versions) do
    table_name
    |> Dynamo.delete_table()
    |> ExAws.request!()

    versions
    |> Enum.filter(&(table_name == &1[:table_name]))
    |> Enum.each(fn version ->
      Dynamo.delete_item(@table, %{version: version[:version]})
      |> ExAws.request!()
    end)
  end

  defp table_names do
    Dynamo.list_tables()
    |> ExAws.request!()
    |> Map.get("TableNames", [])
  end
end
