defmodule DPS.Validator do
  use GenServer
  require Logger

  @validator_config "config/validator_config.yml"

  ## Client ##

  @spec start_link(reference) :: {:ok, pid}
  def start_link(cache) do
    GenServer.start_link(__MODULE__, cache)
  end

  @doc """
  Determines whether given message is valid or invalid.
  It checks if message timestamp is newer than existing record, if all required
  fields are present, and whether all dependencies exist for successful processing
  of the message.
  """
  @spec process(pid, map) :: :ok
  def process(pid, data) do
    GenServer.call(pid, {:validate, data})
  end

  ## Server ##

  def init(cache) do
    state =
      %{config: YamlElixir.read_from_file(@validator_config),
        cache:  cache}
    {:ok, state}
  end

  def handle_call({:validate, data}, _from, state) do
    result =
      data
      |> generate_keys(state.config[data["table"]]["references"])
      |> retrieve_keys(state.cache)
      |> Enum.find(fn(kv_pair) -> validate_key(kv_pair) == :error end)

    case result do
      nil ->
        # send_to_transformer(data)
        {:reply, :ok, state}
      _   ->
        {:reply, :error, state}
    end

    # Enum.map keys, fn(key, value) ->
    #   if value == nil do
    #     if record = sql_query(key) do
    #       update_cache(key, record.timestamp)
    #       key,value
    #     else
    #       :invalid
    #     end
    #   else
    #     key,value
    #   end
    # end
  end

  def validate_key({key, nil}) do
    case check_db(key) do
      nil    -> :error
      record -> update_cache(key, record.timestamp)
    end
  end
  def validate_key(tuple), do: tuple

  @doc """
  Generates a list of strings used to query the validation cache.
  The keys the following convention: "table_name:value1:value2:..."
  The values after the table_name represent the primary key of records to retrieve.
  Ex: "ivmast:H837:ABC"
  """
  @spec generate_keys(map, map | nil) :: [String.t] | []
  def generate_keys(_data, nil), do: []
  def generate_keys(data, references) do
    Enum.map references, fn({table, fields}) ->
      [table | Enum.map(fields, fn(field) -> data[field] end)]
      |> Enum.join(":")
    end
  end

  @spec retrieve_keys([String.t] | [], reference) :: [tuple]
  def retrieve_keys(keys, cache) do
    DPS.ValidationCache.get(cache, keys)
  end
end
