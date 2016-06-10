defmodule DPS.ValidationCacheTest do
  use ExUnit.Case, async: true
  use Timex
  alias DPS.ValidationCache, as: Cache

  setup_all do
    {:ok, [cache: Cache.new_table(:cache)]}
  end

  test "setting a single key as a tuple returns true", %{cache: cache} do
    assert Cache.set(cache, {"some_key", "some_value"}) == true
  end

  test "setting multiple keys as list of tuples returns true", %{cache: cache} do
    result = Cache.set(cache, [{"ivmast:34:ABC", Time.now}, {"hey!", Time.now}])
    assert result == true
  end

  test "retrieving keys returns a list of tuples", %{cache: cache} do
    Cache.set(cache, [key1: :value1, key2: :value2])
    assert Cache.get(cache, [:key1]) == [key1: :value1]
    assert Cache.get(cache, [:key1, :key2]) == [key1: :value1, key2: :value2]
    assert Cache.get(cache, ["no_key1", "no_key2"]) == [nil, nil]
  end

  test "retrieving keys returns an empty list when given an empty list", context do
    assert Cache.get(context.cache, []) == []
  end
end
