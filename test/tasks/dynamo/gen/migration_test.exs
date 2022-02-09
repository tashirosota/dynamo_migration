defmodule Mix.Tasks.Dynamo.Gen.MigrationTest do
  use ExUnit.Case
  doctest Mix.Tasks.Dynamo.Gen.Migration

  test "run" do
    before_files = File.ls(DynamoMigration.migration_file_path())
    Mix.Tasks.Dynamo.Gen.Migration.run(["create_cli_tests_table", "-t", "cli_tests"])
    after_files = File.ls(DynamoMigration.migration_file_path())
    assert before_files != after_files
  end
end
