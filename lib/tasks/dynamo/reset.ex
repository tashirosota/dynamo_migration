defmodule Mix.Tasks.Dynamo.Reset do
  use Mix.Task
  @shortdoc "Drops tables and execs migration files/"
  @aliases [
    p: :prefix
  ]

  @switches [
    prefix: :string
  ]

  @spec run(any) :: :ok
  def run(args) do
    case OptionParser.parse!(args, strict: @switches, aliases: @aliases) do
      {[prefix: prefix], []} ->
        DynamoMigration.reset(prefix)

      _ ->
        DynamoMigration.reset()
    end
  end
end
