defmodule DPS.ConsumerTest do
  use ExUnit.Case, async: true

  test "JSON is converted to a map" do
    json = """
      {"table": "ivmast", "ivitem": "X234567Z", "record_catalog": "ABC"}
    """
    expected_map = %{
      "table" => "ivmast",
      "ivitem" => "X234567Z",
      "record_catalog" => "ABC"
    }

    assert DPS.Consumer.convert_to_map(json) == expected_map
  end
end
