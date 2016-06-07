defmodule DPS.ValidatorTest do
  use ExUnit.Case, async: true

  setup do
    config = %{config: YamlElixir.read_from_file("config/validator_config.yml")}
    {:ok, config}
  end

  test "keys are generated when a table has dependencies", %{config: config} do
    keys = %{
      "table" => "sycclass",
      "sccscl" => "123",
      "scclgp" => "02",
      "record_catalog" => "ABC"
    } |> DPS.Validator.generate_keys(config["sycclass"]["references"])
    assert keys == ["sycgroup:02:ABC"]
  end

  test "keys are generated with arbitrary references" do
    references =
      %{"some_table" => ["cajun_filet", "tea"],
        "another_table" => ["boberry", "coffee"]}
    keys = %{
      "table" => "bojangle",
      "cajun_filet" => 3,
      "boberry" => "biscuit",
      "tea" => "sweet",
      "coffee" => "black"
    } |> DPS.Validator.generate_keys(references)
    assert keys = ["some_table:3:sweet", "another_table:biscuit:black"]
  end

  test "nil is returned when a table has no dependencies" do
    assert DPS.Validator.generate_keys(%{"table" => "some_table"}, nil) == nil
  end
end
