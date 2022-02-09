defmodule Mix.Tasks.Dynamo.ResetTest do
  use ExUnit.Case
  doctest Mix.Tasks.Dynamo.Reset

  test "run" do
    assert Mix.Tasks.Dynamo.Reset.run([]) == :ok
  end
end
