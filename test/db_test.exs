defmodule DBTest do
  use ExUnit.Case

  test "creating tables from a config" do
    YamlElixir.read_from_file("config/dps_config.yml")
    |> DB.create_tables

    results = """
    select table_name from information_schema.tables
    where table_name in ('customer_classes', 'customer_groups')
    """
    |> DB.execute_query

    assert results.num_rows == 2
  end
end
