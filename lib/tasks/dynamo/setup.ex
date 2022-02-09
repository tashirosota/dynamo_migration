defmodule Mix.Tasks.Dynamo.Setup do
  use Mix.Task
  @shortdoc "Creates migrations table"

  @spec run(any) :: :ok
  def run(_) do
    DynamoMigration.setup()
  end
end
