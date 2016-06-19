defmodule DPS.Validator do
  use GenServer
  require Logger

  ## Client ##

  @spec start_link(reference, map) :: {:ok, pid}
  def start_link(cache, config) do
    GenServer.start_link(__MODULE__, {cache, config})
  end

  @doc """
  Determines whether given message is valid or invalid.
  It checks if message timestamp is newer than existing record, if all required
  fields are present, and whether all dependencies exist for successful processing
  of the message.
  """
  @spec process(pid, %{String.t => String.t}) :: :ok
  def process(pid, message) do
    GenServer.call(pid, {:validate, message})
  end

  ## Server ##

  def init({cache, config}) do
    {:ok, %{config: config, cache: cache}}
  end

  @spec handle_call({:validate, map}, reference, map) :: tuple
  def handle_call({:validate, message}, _from, state) do
    config = state.config[message["message_type"]]

    message
    |> generate_cache_keys(config["references"])
    |> retrieve_cache_keys(state.cache)
    |> validate_cache_results(state.cache, state.config)
    |> case do
      true  ->
        # DPS.Transformer.process(message, state.config)
        {:reply, :valid, state}
      false ->
        # return response code also
        {:reply, :invalid, state}
    end
  end

  @doc """
  Generates a stream of strings used to query the validation cache.
  The keys use the following convention: "table_name:value1:value2:..."
  The values after the table_name represent the primary key of that record.
  Ex: "ivmast:H837:ABC" -> ivitem H837, record_catalog ABC
  """
  @spec generate_cache_keys(map, map | nil) :: [String.t] | []
  def generate_cache_keys(_message, nil), do: []
  def generate_cache_keys(message, references) do
    Enum.map references, fn({table, fields}) ->
      [table | Enum.map(fields, fn(field) -> message[field] end)]
      |> Enum.join(":")
    end
  end

  @spec retrieve_cache_keys([String.t] | [], reference) :: [tuple] | []
  def retrieve_cache_keys(keys, cache) do
    Enum.map keys, fn(key) ->
      DPS.ValidationCache.get(cache, key)
    end
  end

  @spec validate_cache_results([tuple], reference, map) :: boolean
  def validate_cache_results(results, cache, config) do
    Enum.all? results, fn
      {key, nil} -> self_healing_cache_check(cache, key, config)
      _          -> true
    end
  end

  @spec self_healing_cache_check(reference, String.t, map) :: boolean
  def self_healing_cache_check(cache, key, config) do
    case query_database_for_key(key, config) do
      []       -> false
      [record] -> update_cache(cache, key, record.record_timestamp)
    end
  end

  @spec query_database_for_key(String.t, map) :: map | nil
  def query_database_for_key(cache_key, config) do
    [table | values] = String.split(cache_key, ":")
    where_constraints =
      config[table]["primary_key"]
      |> Enum.map(&(String.to_atom/1))
      |> Enum.zip(values)
    DB.select_all(table, where_constraints)
  end

  @spec update_cache(reference, String.t, any) :: true
  def update_cache(cache, key, value) do
    DPS.ValidationCache.set(cache, {key, value})
  end
end
