defmodule Mix.Tasks.Dynamo.Reset do
  use Mix.Task
  @shortdoc "Drops tables and execs migration files/"
  @aliases [
    p: :prefix,
    e: :env_prefix
  ]

  @switches [
    prefix: :string,
    env_prefix: :boolean
  ]

  @spec run(any) :: :ok
  def run(args) do
    case OptionParser.parse!(args, strict: @switches, aliases: @aliases) do
      {[prefix: prefix], []} ->
        DynamoMigration.reset(prefix)

      {[env_prefix: true], []} ->
        DynamoMigration.reset("#{Mix.env()}.")

      _ ->
        DynamoMigration.reset()
    end
  end
end
