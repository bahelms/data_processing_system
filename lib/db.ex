defmodule DB do
  @moduledoc """
  General functions to aid database management
  """

  def select_all(table, options \\ []) do
    "select * from #{table} where #{where_clause(options)}"
    |> DB.execute_query
  end

  @spec create_tables(DPS.config) :: any
  def create_tables(config) do
    Enum.map config, fn({_source, config}) ->
      create_table_template(config)
      |> execute_query
    end
  end

  @spec execute_query(String.t, [String.t]) :: %Postgrex.Result{}
  def execute_query(query, args \\ []) do
    {:ok, result} = Ecto.Adapters.SQL.query(DPS.Repo, query, args)
    result
  end

  defp where_clause(options) do
    options
    |> Enum.map(fn({field, value}) -> "#{field} = '#{value}'" end)
    |> Enum.join(" and ")
  end

  @spec generate_fields(DPS.config) :: String.t
  defp generate_fields(schema) do
    Enum.map(schema, fn({field, type}) -> "#{field} #{type}" end)
    |> Enum.concat(meta_fields)
    |> Enum.join(",")
  end

  @spec create_table_template(DPS.config) :: String.t
  defp create_table_template(config) do
    # Add constraints (primary key, not null, foreign key)
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
