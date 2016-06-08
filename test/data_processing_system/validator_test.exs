defmodule DPS.ValidatorTest do
  use ExUnit.Case, async: true

  setup do
    context = %{
      config: YamlElixir.read_from_file("config/validator_config.yml"),
      sample_data: %{
        "table"          => "sycclass",
        "sccscl"         => "123",
        "scclgp"         => "02",
        "record_catalog" => "ABC"
      }
    }
    {:ok, context}
  end

  test "keys are generated when a table has dependencies", context do
    keys =
      context.sample_data
      |> DPS.Validator.generate_keys(context.config["sycclass"]["references"])
    assert keys == ["sycgroup:02:ABC"]
  end

  test "keys are generated with arbitrary references" do
    references =
      %{"some_table"    => ["cajun_filet", "tea"],
        "another_table" => ["boberry", "coffee"]}

    keys =
      %{"table"       => "bojangle",
        "cajun_filet" => 3,
        "boberry"     => "biscuit",
        "tea"         => "sweet",
        "coffee"      => "black"}
      |> DPS.Validator.generate_keys(references)
      |> Enum.sort
    assert keys == ["another_table:biscuit:black", "some_table:3:sweet"]
  end

  test "nil is returned when a table has no dependencies" do
    assert DPS.Validator.generate_keys(%{"table" => "some_table"}, nil) == nil
  end

  test ":ok is returned when all dependencies exist", %{sample_data: data} do
    {:ok, pid} = DPS.Validator.start_link
    assert DPS.Validator.process(pid, data) == :ok
  end

  test ":error is returned when the message is invalid", %{sample_data: data} do
    {:ok, pid} = DPS.Validator.start_link
    assert DPS.Validator.process(pid, data) == :error
  end
end
