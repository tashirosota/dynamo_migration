defmodule Mix.Tasks.Dynamo.SetupTest do
  use ExUnit.Case
  doctest Mix.Tasks.Dynamo.Setup

  test "run" do
    assert Mix.Tasks.Dynamo.Setup.run([]) == :ok
  end
end
