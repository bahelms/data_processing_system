defmodule DPS.TransformerTest do
  use ExUnit.Case, async: true

  setup do
    context =
      %{message: %{
          "message_type"     => "sycclass",
          "sccscl"           => "123",
          "scclgp"           => "02",
          "record_catalog"   => "ABC",
          "record_mode"      => "insert",
          "record_timestamp" => "2015-10-23T14:17:46.339713"
        },
        config: YamlElixir.read_from_file("config/dps_config.yml")}
    {:ok, context}
  end

  @tag :pending
  test "processing a message persists a source and public version" do
  end

  test "creating a subset of the message to persist as source", context do
    expected_data =
      %{"sccscl"           => "123",
        "scclgp"           => "02",
        "record_catalog"   => "ABC",
        "record_timestamp" => "2015-10-23T14:17:46.339713"}

    assert DPS.Transformer.extract_source_data(context.message, context.config) ==
      expected_data
  end

  test "transforming message to the public version", context do
    expected_data =
      %{"code"                => "123",
        "customer_group_code" => "02",
        "division"            => "ABC"}

    assert DPS.Transformer.transform(context.message, context.config) ==
      expected_data
  end
end
