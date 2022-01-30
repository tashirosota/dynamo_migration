defmodule Mix.Tasks.Dynamo.MigrateTest do
  use ExUnit.Case
  doctest Mix.Tasks.Dynamo.Migrate

  test "run" do
    assert Mix.Tasks.Dynamo.Migrate.run([]) == :ok
  end
end
