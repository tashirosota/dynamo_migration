defmodule DynamoMigrationTest do
  use ExUnit.Case
  doctest DynamoMigration

  test "greets the world" do
    assert DynamoMigration.hello() == :world
  end
end
