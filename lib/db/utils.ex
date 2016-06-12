defmodule DB.Utils do
  require Logger

  @config_file "config/dps_config.yml"

  def create_tables do
    Logger.info "Creating tables from #{@config_file}..."
    YamlElixir.read_from_file(@config_file)
    |> Enum.map(fn({source, config}) ->
      create_table_template(config)
      |> execute_query
    end)
  end

  @spec execute_query(String.t, [String.t]) :: %Postgrex.Result{}
  def execute_query(query, args \\ []) do
    {:ok, result} = Ecto.Adapters.SQL.query(DPS.Repo, query, args)
    result
  end

  @spec generate_fields(%{String.t => String.t}) :: String.t
  defp generate_fields(schema) do
    Enum.map(schema, fn({field, type}) -> "#{field} #{type}" end)
    |> Enum.concat(meta_fields)
    |> Enum.join(",")
  end

  @spec create_table_template(%{String.t => String.t}) :: String.t
  defp create_table_template(config) do
    # Add constraints
    """
    CREATE TABLE IF NOT EXISTS #{config["table"]}
    (#{generate_fields(config["fields"])})
    """
  end

  @spec meta_fields :: [String.t]
  defp meta_fields do
    ["id uuid"]
  end
end
