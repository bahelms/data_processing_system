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

  test "retrieving key returns a list of one tuples", %{cache: cache} do
    Cache.set(cache, [key1: :value1, key2: :value2])
    assert Cache.get(cache, :key1) == {:key1, :value1}
    assert Cache.get(cache, "no_key1") == {"no_key1", nil}
  end
end
