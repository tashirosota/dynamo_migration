defmodule Mix.Tasks.Dynamo.Gen.Migration do
  use Mix.Task
  import Macro, only: [camelize: 1, underscore: 1]
  import Mix.Generator

  @shortdoc "Generates a new migration file for DynamoDB"
  @aliases [
    t: :table,
    e: :env_prefix
  ]

  @switches [
    table: :string,
    env_prefix: :boolean,
    change: :string
  ]

  @spec run([String.t()]) :: integer()
  def run(args) do
    case OptionParser.parse!(args, strict: @switches, aliases: @aliases) do
      {opts, [file_name]} ->
        if opts[:table] do
          process(file_name, opts)
        else
          Mix.raise(
            "expected dynamo.gen.migration to receive the table name, " <>
              "got: #{inspect(Enum.join(args, " "))}"
          )
        end

      _ ->
        Mix.raise(
          "expected dynamo.gen.migration to receive the migration file name, " <>
            "got: #{inspect(Enum.join(args, " "))}"
        )
    end
  end

  defp process(file_name, opts) do
    table_name = opts[:table]
    include_env_prefix = !!opts[:env_prefix]

    change =
      opts[:change] ||
        """
            # ## You can freely write operations related to DynamoDB.
            # ### Examples.
            # ExAws.Dynamo.create_table(
            #   "Tests", # You may type `Mix.env() <> "table_name"` if want to use it properly want by environment.
            #   [id: :hash],
            #   %{id: :number},
            #   1,
            #   1,
            #   :provisioned
            # )
            # |> ExAws.request!()
        """

    migrations_path = DynamoMigration.migration_file_path()
    base_name = "#{underscore(file_name)}.exs"
    current_timestamp = timestamp()
    file = Path.join(migrations_path, "#{current_timestamp}_#{base_name}")
    unless File.dir?(migrations_path), do: create_directory(migrations_path)
    fuzzy_path = Path.join(migrations_path, "*_#{base_name}")

    if Path.wildcard(fuzzy_path) != [],
      do:
        Mix.raise(
          "migration can't be created, there is already a migration file with name #{file_name}."
        )

    assigns = [
      mod: Module.concat([Dynamo, Migrations, camelize(file_name)]),
      table:
        (include_env_prefix && "\#{Mix.env()}.#{table_name}") ||
          table_name,
      change: change
    ]

    create_file(file, migration_template(assigns))
    current_timestamp |> String.to_integer()
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)

  embed_template(:migration, """
  defmodule <%= inspect @mod %> do
    @table_name "<%=@table %>"

    def table_name, do: @table_name

    def change do

  <%=@change %>
    end
  end
  """)
end
