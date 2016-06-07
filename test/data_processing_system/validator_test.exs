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
    } |> DPS.Validator.generate_keys(config)
    assert keys == ["sycgroup:02:ABC"]
  end

  test "nil is returned when a table has no dependencies", %{config: config} do
    keys = DPS.Validator.generate_keys(%{"table" => "sycgroup"}, config)
    assert keys == nil
  end
end
