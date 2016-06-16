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
  Inserts one key/value tuple into the cache table.
  """
  @spec set(reference, tuple) :: true
  def set(cache, entry) do
    :ets.insert(cache, entry)
  end

  @doc """
  Retrieves a list of one key/value tuple corresponding to the given key
  """
  @spec get(reference, String.t) :: tuple
  def get(cache, key) do
    case :ets.lookup(cache, key) do
      [tuple] -> tuple
      []      -> {key, nil}
    end
  end
end
