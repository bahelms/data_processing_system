defmodule DPS.ValidatorTest do
  use ExUnit.Case, async: true
  alias DPS.ValidationCache, as: Cache

  setup do
    context = %{
      config: YamlElixir.read_from_file("config/dps_config.yml"),
      sample_data: %{
        "table"          => "sycclass",
        "sccscl"         => "123",
        "scclgp"         => "02",
        "record_catalog" => "ABC"
      },
      cache: Cache.new_table(:cache)
    }
    {:ok, context}
  end

  test "keys are generated when a table has references", context do
    references = context.config["sycclass"]["references"]
    mapping = context.config["sycclass"]["source_mapping"]
    keys = DPS.Validator.generate_keys(context.sample_data, references, mapping)
    assert keys == ["sycgroup:02:ABC"]
  end

  test "generating keys with no references returns an empty list" do
    assert DPS.Validator.generate_keys(%{"table" => "some_table"}, nil, nil) == []
  end

  test "keys can be generated with arbitrary references" do
    references =
      %{"some_table"    => ["cajun_filet", "tea"],
        "another_table" => ["boberry", "coffee"]}
    mapping =
      %{"cajun_filet" => "CF",
        "tea"         => "TE",
        "boberry"     => "BB",
        "coffee"      => "CE"}
    keys =
      %{"table" => "bojangle",
        "CF"    => 3,
        "BB"    => "biscuit",
        "TE"    => "sweet",
        "CE"    => "black"}
      |> DPS.Validator.generate_keys(references, mapping)
      |> Enum.sort
    assert keys == ["another_table:biscuit:black", "some_table:3:sweet"]
  end

  test "retrieving keys returns a list of tuples", context do
    Cache.set(context.cache, [{"sycgroup:123:ABC", :value}])
    result =
      ["sycgroup:123:ABC", :bad_key]
      |> DPS.Validator.retrieve_keys(context.cache)
    assert result == [{"sycgroup:123:ABC", :value}, {:bad_key, nil}]
  end

  test "validating keys when all references exist" do
    result =
      [{"key1", :value}, {"key2", :value}]
      |> DPS.Validator.validate_keys(nil)
    assert result == :valid
  end

  test "validating keys when the reference doesn't exist" do
    result =
      [{"key1", :value}, {"key2", nil}]
      |> DPS.Validator.validate_keys(nil)
    assert result == {"key2", nil}
  end

  test "checking a key when the value is not nil" do
    assert DPS.Validator.check_key({"hey", "there"}, nil) == :valid
  end

  test "checking a key when the reference does not exist" do
    assert DPS.Validator.check_key({"hey", nil}, nil) == :error
  end

  test "checking a key when reference is in DB but not in cache", context do
    timestamp = :os.timestamp # give this to DB
    # set DB
    assert DPS.Validator.check_key({:hey, nil}, context.cache) == :valid
    assert Cache.get(context.cache, [:hey]) == [hey: timestamp]
  end

  @tag :pending
  test "query_database" do
  end

  test "updating the cache", %{cache: cache} do
    assert DPS.Validator.update_cache(cache, :whats, :up?) == true
    assert Cache.get(cache, [:whats]) == [whats: :up?]
  end

  ## process/2 - validation acceptance ##

  test ":ok is returned when all dependencies exist", context do
    Cache.set(context.cache, [{"sycgroup:02:ABC", :os.timestamp}])
    {:ok, pid} = DPS.Validator.start_link(context.cache)
    assert DPS.Validator.process(pid, context.sample_data) == :ok
  end

  test ":error is returned when the message is invalid", context do
    {:ok, pid} = DPS.Validator.start_link(context.cache)
    assert DPS.Validator.process(pid, context.sample_data) == :error
  end
end
