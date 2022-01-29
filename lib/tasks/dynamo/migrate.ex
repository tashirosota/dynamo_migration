defmodule Mix.Tasks.Dynamo.Migrate do
  @requirements ["app.start"]
  use Mix.Task
  @shortdoc "Mix.Tasks.Dynamo.Migrate"

  def run(_) do
    DynamoMigration.migrate()
  end
end
