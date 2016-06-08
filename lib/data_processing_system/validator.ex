defmodule DPS.Validator do
  use GenServer
  require Logger

  @validator_config "config/validator_config.yml"

  ## Client ##

  def start_link do
    GenServer.start_link(__MODULE__, [])
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

  def init([]) do
    state = %{config: YamlElixir.read_from_file(@validator_config)}
    {:ok, state}
  end

  def handle_call({:validate, data}, _from, state) do
    generate_keys(data, state.config[data["table"]]["references"])

    # retrieve keys
    # if valid?
    #   send data to transformer
    # else
    #   generate response
    #   send to response topic
    {:reply, :ok, state}
  end

  @doc """
  Generates a list of strings used to query the validation cache.
  The keys the following convention: "table_name:value1:value2:..."
  The values after the table_name represent the primary key of records to retrieve.
  Ex: "ivmast:H837:ABC"
  """
  @spec generate_keys(map, map | nil) :: String.t | nil
  def generate_keys(_data, nil), do: nil
  def generate_keys(data, references) do
    Enum.map references, fn({table, fields}) ->
      [table | Enum.map(fields, fn(field) -> data[field] end)]
      |> Enum.join(":")
    end
  end
end
