defmodule Mix.Tasks.Dynamo.Migrate do
  @requirements ["app.start"]
  use Mix.Task
  @shortdoc "Mix.Tasks.Dynamo.Migrate"

  @spec run(any) :: :ok
  def run(_) do
    DynamoMigration.migrate()
  end
end
