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
      },
      cache: DPS.ValidationCache.new_table(:cache)
    }
    {:ok, context}
  end

  test "keys are generated when a table has references", context do
    keys =
      context.sample_data
      |> DPS.Validator.generate_keys(context.config["sycclass"]["references"])
    assert keys == ["sycgroup:02:ABC"]
  end

  test "generating keys with no references returns an empty list" do
    assert DPS.Validator.generate_keys(%{"table" => "some_table"}, nil) == []
  end

  test "keys can be generated with arbitrary references" do
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

  test "retrieving keys returns a list of tuples", context do
    DPS.ValidationCache.set(context.cache, [{"sycgroup:123:ABC", :value}])
    result =
      DPS.Validator.retrieve_keys(["sycgroup:123:ABC", :bad_key], context.cache)
    assert result == [{"sycgroup:123:ABC", :value}, nil]
  end

  @tag :pending
  test "validating keys" do
  end

  @tag :pending
  test "check_key" do
  end

  @tag :pending
  test "query_db" do
  end

  @tag :pending
  test "update_cache" do
  end

  ## process/2 - validation acceptance ##

  test ":ok is returned when all dependencies exist", context do
    DPS.ValidationCache.set(context.cache, [{"sycgroup:02:ABC", :os.timestamp}])
    {:ok, pid} = DPS.Validator.start_link(context.cache)
    assert DPS.Validator.process(pid, context.sample_data) == :ok
  end

  test ":error is returned when the message is invalid", context do
    {:ok, pid} = DPS.Validator.start_link(context.cache)
    assert DPS.Validator.process(pid, context.sample_data) == :error
  end
end
