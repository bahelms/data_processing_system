defmodule DB.UtilsTest do
  use ExUnit.Case

  test "creating tables from a config" do
    DB.Utils.create_tables

    results = """
    select table_name from information_schema.tables
    where table_name in ('customer_classes', 'customer_groups')
    """
    |> DB.Utils.execute_query

    assert results.num_rows == 2
  end

  test "dropping tables from config" do
    DB.Utils.drop_tables

    results = """
    select table_name from information_schema.tables
    where table_name in ('customer_classes', 'customer_groups')
    """
    |> DB.Utils.execute_query

    assert results.num_rows == 0
  end
end
