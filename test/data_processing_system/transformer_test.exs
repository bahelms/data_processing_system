defmodule DPS.TransformerTest do
  use ExUnit.Case, async: true

  setup do
    context =
      %{sycclass_message: %{
          "message_type"     => "sycclass",
          "sccscl"           => "123",
          "scclgp"           => "02",
          "record_catalog"   => "ABC",
          "record_mode"      => "insert",
          "record_timestamp" => "2015-10-23T14:17:46.339713"
        },
        sycgroup_message: %{
          "message_type"     => "sycgroup",
          "sgclgp"           => "02",
          "sgclcd"           => "",
          "sggpds"           => "desc",
          "record_catalog"   => "ABC",
          "record_mode"      => "insert",
          "record_timestamp" => "2015-10-23T14:17:46.339713"
        },
        config: YamlElixir.read_from_file("config/dps_config.yml")}
    {:ok, context}
  end

  @tag :pending
  test "processing a message persists a source and public version", context do
    DPS.Transformer.process(context.sycgroup_message)
  end

  test "creating a subset of the message to persist as source", context do
    expected_data =
      %{"sccscl"           => "123",
        "scclgp"           => "02",
        "record_catalog"   => "ABC",
        "record_timestamp" => "2015-10-23T14:17:46.339713"}

    result =
      context.sycclass_message
      |> DPS.Transformer.extract_source_data(context.config)
    assert result == expected_data
  end

  test "transforming message to the public version without references", context do
    expected_data =
      %{"code"        => "02",
        "division"    => "ABC",
        "description" => "desc",
        "delete_code" => nil}

    result =
      context.sycgroup_message
      |> DPS.Transformer.transform(context.config["customer_groups"])
    assert result == expected_data
  end

  test "sanitizing data" do
    assert DPS.Transformer.sanitize("") == nil
    assert DPS.Transformer.sanitize("      ") == nil
    assert DPS.Transformer.sanitize("   hey") == "hey"
    assert DPS.Transformer.sanitize("you   ") == "you"
    assert DPS.Transformer.sanitize(" what? ") == "what?"
  end
end
