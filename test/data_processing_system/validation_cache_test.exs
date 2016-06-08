defmodule DPS.ValidationCacheTest do
  use ExUnit.Case, async: true
  use Timex
  alias DPS.ValidationCache, as: Cache

  setup_all do
    {:ok, cache} = Cache.start_link
    {:ok, [cache: cache]}
  end

  test "setting a single key as a tuple returns :ok", %{cache: cache} do
    assert Cache.set(cache, {"some_key", "some_value"}) == :ok
  end

  test "setting multiple keys as list of tuples returns count", %{cache: cache} do
    result = Cache.set(cache, [{"ivmast:34:ABC", Time.now}, {"hey!", Time.now}])
    assert result == 2
  end

  test "retrieving a single key", %{cache: cache} do
    Cache.set(cache, {"hey_there", "how you durin?"})
    assert Cache.get(cache, "hey_there") == "how you durin?"
  end

  test "retrieving multiple keys", %{cache: cache} do
    Cache.set(cache, [{"key1", "value1"}, {"key2", "value2"}])
    assert Cache.get(cache, ["key1", "key2"]) == ["value1", "value2"]
  end
end
