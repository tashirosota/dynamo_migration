defmodule Mix.Tasks.Dynamo.Gen.MigrationTest do
  use ExUnit.Case
  doctest Mix.Tasks.Dynamo.Gen.Migration

  test "run" do
    before_files = File.ls(DynamoMigration.migration_file_path())
    Mix.Tasks.Dynamo.Gen.Migration.run(["create_cli_tests_table"])
    after_files = File.ls(DynamoMigration.migration_file_path())
    before_files |> IO.inspect()
    after_files |> IO.inspect()
    assert before_files != after_files
  end
end
