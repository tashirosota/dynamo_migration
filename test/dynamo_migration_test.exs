defmodule DynamoMigrationTest do
  use ExUnit.Case, async: true
  doctest DynamoMigration

  setup_all do
    Mix.Tasks.Dynamo.Setup.run([])
  end

  setup do
    Process.sleep(1000)
    table_name = random_prefix() <> "tests"

    version =
      Mix.Tasks.Dynamo.Gen.Migration.run([
        "create_#{table_name}_table",
        "-t",
        table_name,
        "--change",
        change(table_name)
      ])

    {:ok, version: version}
  end

  describe "reset/1" do
    test ":ok" do
      assert :ok = DynamoMigration.reset()
    end
  end

  describe "migration" do
    test "migration_required? && migrate", %{version: version} do
      assert DynamoMigration.migration_required?(version)
      assert :ok = DynamoMigration.migrate()
      refute DynamoMigration.migration_required?(version)
    end
  end

  test "setup" do
    assert DynamoMigration.setup() == :ok
  end

  test "migration_file_path" do
    assert DynamoMigration.migration_file_path() == "priv/dynamo/migrations"
  end

  defp random_prefix() do
    length = 5

    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> binary_part(0, length)
    |> String.replace("/", "")
    |> String.replace("+", "")
    |> String.replace(~r/[0-9]/, "")
  end

  defp change(table_name) do
    """
        ExAws.Dynamo.create_table(
          "#{table_name}",
          [id: :hash],
          %{id: :number},
          1,
          1,
          :provisioned
        )
        |> ExAws.request!()
    """
  end
end
