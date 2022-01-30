defmodule DynamoMigrationTest do
  use ExUnit.Case, async: true
  doctest DynamoMigration

  setup_all do
    Mix.Tasks.Dynamo.Setup.run([])
  end

  setup do
    Process.sleep(1000)
    length = 5

    random =
      :crypto.strong_rand_bytes(length)
      |> Base.encode64()
      |> binary_part(0, length)
      |> String.replace("/", "")
      |> String.replace(~r/[0-9]/, "")

    version = Mix.Tasks.Dynamo.Gen.Migration.run([random <> "create_tests_table"])
    {:ok, version: version}
  end

  describe "migration" do
    test "migration_required? && migrate?", state do
      assert DynamoMigration.migration_required?(state[:version]) == true
      assert DynamoMigration.migrate() == :ok
      assert DynamoMigration.migration_required?(state[:version]) == false
    end
  end

  test "setup" do
    DynamoMigration.setup() == :ok
  end

  test "migration_file_path" do
    assert DynamoMigration.migration_file_path() == "priv/dynamo/migrations"
  end
end
