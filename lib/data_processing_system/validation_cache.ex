defmodule DPS.ValidationCache do
  @moduledoc """
  This module manages a GenServer that contains a map of key/value pairs.
  Each key corresponds to a record that has already been successfully processed.
  The value of those keys is that record's timestamp.

  The keys use the following convention: "table_name:value1:value2:..."
  The values after the table name represent the primary key of that record.
  Ex: "ivmast:H837:ABC"
  """
  use GenServer

  ## Client ##

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  @doc """
  Inserts either one tuple or a list of tuples into the state
  """
  @spec set(pid, [tuple, ...] | tuple) :: :ok | integer
  def set(pid, entries) do
    GenServer.call(pid, {:set, entries})
  end

  @doc """
  Retrieves either one value for a given key or a list of values for a list
  of keys.
  """
  @spec get(pid, [String.t, ...] | String.t) :: [String.t, ...] | String.t
  def get(pid, keys) do
    GenServer.call(pid, {:get, keys})
  end

  ## Server ##

  def handle_call({:set, {key, value}}, _from, state) do
    {:reply, :ok, Map.put(state, key, value)}
  end

  def handle_call({:set, entries}, _from, state) do
    state = Map.merge(state, Enum.into(entries, %{}))
    {:reply, length(entries), state}
  end

  def handle_call({:get, keys}, _from, state) when is_list(keys) do
    values = state |> Map.take(keys) |> Map.values
    {:reply, values, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end
end
