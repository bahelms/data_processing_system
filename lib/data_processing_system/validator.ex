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
  @spec process(pid, map) :: :ok
  def process(pid, message) do
    GenServer.call(pid, {:validate, message})
  end

  ## Server ##

  def init({cache, config}) do
    {:ok, %{config: config, cache: cache}}
  end

  def handle_call({:validate, message}, _from, state) do
    config = state.config[message["message_type"]]

    message
    |> generate_cache_keys(config["references"])
    |> retrieve_cache_keys(state.cache)

    # |> Enum.all?(fn
    #   {key, nil} ->
    #     case DB.execute_query(generate_sql(key)) do
    #       nil    -> false
    #       record ->
    #         update_cache(state.cache, key, record.timestamp)
    #         true
    #     end
    #   _ -> true
    # end)
    # |> case do
    #   true  ->
    #     # send_to_transformer(message)
    #     {:reply, :ok, state}
    #   false ->
    #     # return response code also
    #     {:reply, :error, state}
    # end
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

  @spec retrieve_cache_keys(Stream.t | [], reference) :: Stream.t
  def retrieve_cache_keys(keys, cache) do
    Stream.map keys, fn(key) ->
      DPS.ValidationCache.get(cache, key)
    end
  end

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
