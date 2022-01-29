defmodule Mix.Tasks.Dynamo.Setup do
  @requirements ["app.start"]
  use Mix.Task
  @shortdoc "Mix.Tasks.Dynamo.Setup"

  def run(_) do
    DynamoMigration.setup()
  end
end
