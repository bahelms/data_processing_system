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
      |> validate_keys(state.cache)

    case result do
      :valid ->
        # send_to_transformer(data)
        {:reply, :ok, state}
      _ ->
        # return response code also
        {:reply, :error, state}
    end
  end

  @doc """
  Generates a list of strings used to query the validation cache.
  The keys use the following convention: "table_name:value1:value2:..."
  The values after the table_name represent the primary key of referenced records.
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

  @spec retrieve_keys([String.t] | [], reference) :: [tuple] | []
  def retrieve_keys(keys, cache) do
    DPS.ValidationCache.get(cache, keys)
  end

  @spec validate_keys([tuple] | [], reference) :: tuple | :valid
  def validate_keys(keys, cache) do
    Enum.find keys, :valid, fn(key) ->
      check_key(key, cache) == :error
    end
  end

  @spec check_key(tuple, reference) :: :error | :valid
  def check_key({key, nil}, cache) do
    case query_database(key) do
      nil    -> :error
      record ->
        # I don't like this side effect here
        update_cache(cache, key, record.timestamp)
        :valid
    end
  end
  def check_key(_tuple, _cache), do: :valid

  # @spec query_database(String.t)
  def query_database(key) do
  end

  @spec update_cache(reference, String.t, any) :: true
  def update_cache(cache, key, value) do
    DPS.ValidationCache.set(cache, {key, value})
  end
end
