defmodule DBTest do
  use ExUnit.Case, async: true

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(DPS.Repo)
  end

  test "creating tables from a config" do
    YamlElixir.read_from_file("config/dps_config.yml")
    |> DB.create_tables

    results = """
      select table_name from information_schema.tables
      where table_name in ('sycclass', 'sycgroup')
      """
      |> DB.execute_query
    assert results.num_rows == 2
  end

  test "selecting records with 'where' conditions" do
    "insert into sycclass (sccscl, record_catalog) values ('123', 'ABC')"
    |> DB.execute_query

    res = DB.select_all("sycclass", sccscl: '123', record_catalog: 'ABC')
    assert res.num_rows == 1
  end
end
