defmodule DPS.Validator do
  use GenServer
  require Logger

  @validator_config "config/validator_config.yml"

  ## Client ##

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

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
    generate_keys(data, state.config[data["table"]["references"]])

    # retrieve keys
    # if valid?
    #   send data to transformer
    # else
    #   generate response
    #   send to response topic
    {:reply, :ok, state}
  end

  def generate_keys(_data, nil), do: nil

  @spec generate_keys(map, map) :: String.t
  def generate_keys(data, references) do
    Enum.map references, fn({table, fields}) ->
      [table | Enum.map(fields, fn(field) -> data[field] end)]
      |> Enum.join(":")
    end
  end
end
