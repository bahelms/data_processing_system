defmodule DB.Utils do
  @moduledoc """
  General functions to aid database management
  """

  @type config :: %{String.t => String.t}

  @spec create_tables(config) :: any
  def create_tables(config) do
    Enum.map config, fn({source, config}) ->
      create_table_template(config)
      |> execute_query
    end
  end

  @spec execute_query(String.t, [String.t]) :: %Postgrex.Result{}
  def execute_query(query, args \\ []) do
    {:ok, result} = Ecto.Adapters.SQL.query(DPS.Repo, query, args)
    result
  end

  @spec generate_fields(config) :: String.t
  defp generate_fields(schema) do
    Enum.map(schema, fn({field, type}) -> "#{field} #{type}" end)
    |> Enum.concat(meta_fields)
    |> Enum.join(",")
  end

  @spec create_table_template(config) :: String.t
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
