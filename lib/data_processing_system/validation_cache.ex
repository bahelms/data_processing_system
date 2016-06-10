defmodule DPS.ValidationCache do
  @moduledoc """
  This module manages an ETS table that contains a key/value pairs.
  Each key corresponds to a record that has already been successfully processed.
  The value of those keys is that record's timestamp.

  The keys use the following convention: "table_name:value1:value2:..."
  The values after the table name represent the primary key of that record.
  Ex: "ivmast:H837:ABC"
  """

  @doc """
  Returns a reference to a new ETS table of the given name.
  """
  @spec new_table(atom) :: reference
  def new_table(name) do
    :ets.new(name, [:public])
  end

  @doc """
  Inserts either one tuple or a list of tuples into the cache table.
  """
  @spec set(reference, tuple | [tuple]) :: true
  def set(cache, entries) do
    :ets.insert(cache, entries)
  end

  @doc """
  Retrieves a list of key/value tuples corresponding to the given keys
  """
  @spec get(reference, [String.t] | []) :: [tuple] | []
  def get(cache, keys) do
    Enum.map keys, fn(key) ->
      case :ets.lookup(cache, key) do
        [tuple] -> tuple
        []      -> nil
      end
    end
  end
end
