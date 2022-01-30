defmodule Mix.Tasks.Dynamo.Setup do
  @requirements ["app.start"]
  use Mix.Task
  @shortdoc "Mix.Tasks.Dynamo.Setup"

  @spec run(any) :: :ok
  def run(_) do
    DynamoMigration.setup()
  end
end
