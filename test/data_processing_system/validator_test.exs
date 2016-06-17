defmodule DPS.ValidatorTest do
  use ExUnit.Case, async: true
  alias DPS.ValidationCache, as: Cache

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(DPS.Repo)
    context = %{
      config: YamlElixir.read_from_file("config/dps_config.yml"),
      cache:  Cache.new_table(:cache),
      sample_message: %{
        "message_type"   => "sycclass",
        "sccscl"         => "123",
        "scclgp"         => "02",
        "record_catalog" => "ABC"
      }
    }
    {:ok, context}
  end

  ## process/2 - validation acceptance ##

  test ":ok is returned when all dependencies exist", context do
    Cache.set(context.cache, [{"sycgroup:02:ABC", :os.timestamp}])
    {:ok, pid} = DPS.Validator.start_link(context.cache, context.config)
    assert DPS.Validator.process(pid, context.sample_message) == :ok
  end

  test ":error is returned when the message is invalid", context do
    {:ok, pid} = DPS.Validator.start_link(context.cache, context.config)
    assert DPS.Validator.process(pid, context.sample_message) == :error
  end

  ## unit tests ##

  test "generating keys when a table has references",
    %{config: conf, sample_message: msg} do
    keys = DPS.Validator.generate_cache_keys(msg, conf["sycclass"]["references"])
    assert keys == ["sycgroup:02:ABC"]
  end

  test "generating keys with no references returns an empty list" do
    keys = DPS.Validator.generate_cache_keys(%{"table" => "some_table"}, nil)
    assert keys == []
  end

  test "generating keys with arbitrary references" do
    references =
      %{"some_table"    => ["cajun_filet", "tea"],
        "another_table" => ["boberry", "coffee"]}

    keys =
      %{"message_type" => "bojangle",
        "cajun_filet"  => 3,
        "tea"          => "sweet",
        "boberry"      => "biscuit",
        "coffee"       => "black"}
      |> DPS.Validator.generate_cache_keys(references)
    assert keys == ["another_table:biscuit:black", "some_table:3:sweet"]
  end

  test "retrieving keys returns a stream of key/value tuples", context do
    Cache.set(context.cache, {"customer_groups:123:ABC", :value})
    result =
      ["customer_groups:123:ABC", :bad_key]
      |> DPS.Validator.retrieve_cache_keys(context.cache)
      |> Enum.to_list
    assert result == [{"customer_groups:123:ABC", :value}, {:bad_key, nil}]
  end

  test "querying database with a cache key", context do
    result =
      "sycclass:123:TCI"
      |> DPS.Validator.query_database_for_key(context.config)
    assert result == %Postgrex.Result{}
  end

  # test "querying the database with a cache key", context do
  #   "insert into customer_groups (code, division) values ('123','XYZ')"
  #   |> DB.execute_query

  #   config = context.config[context.sample_message["table"]]
  #   result = DPS.Validator.query_database("sycgroup:123:XYZ", config)
  #   DB.execute_query("truncate customer_groups")

  #   assert result.num_rows == 1
  # end

  test "updating the cache", %{cache: cache} do
    assert DPS.Validator.update_cache(cache, :whats, :up?) == true
    assert Cache.get(cache, :whats) == {:whats, :up?}
  end
end
