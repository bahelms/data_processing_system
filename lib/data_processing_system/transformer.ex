defmodule DPS.Transformer do
  @moduledoc """
  The transformer is responsible for turning the given message into a format
  suitable for persisting as source and public versions. This entails creating
  a subset of the message to use as source and using specific business logic to
  transform and map the message into its public version.
  """

  @spec process(%{String.t => String.t}, map) :: {:ok, pid}
  def process(message, config) do
    DPS.TransformerSupervisor
    |> Task.Supervisor.start_child(__MODULE__, :handle_message, [message, config])
  end

  @spec handle_message(%{String.t => String.t}, map) :: any
  def handle_message(message, config) do
    msg_type     = message["message_type"]
    source_table = config[msg_type]["table"]
    public_table = config[msg_type]["public"]

    DPS.Persister.process(
      {source_table, extract_source_data(message, config)},
      {public_table, transform(message, config[public_table])}
    )
  end

  @doc """
  Extracts a subset of data from the message to use as source data
  """
  @spec extract_source_data(map, map) :: %{String.t => String.t}
  def extract_source_data(message, config) do
    source_fields = config[message["message_type"]]["fields"]
    Enum.reduce message, %{}, fn(msg_field = {key, _value}, source_data) ->
      add_field(msg_field, source_data, Map.has_key?(source_fields, key))
    end
  end

  @spec transform(map, map) :: %{String.t => String.t}
  def transform(message, config) do
    Enum.reduce config["fields"], %{}, fn({field, options}, public_data) ->
      Map.put(public_data, field, sanitize(message[options["source"]]))
    end
  end

  @spec sanitize(String.t) :: %{String.t => String.t}
  def sanitize(value) do
    case String.strip(value) do
      ""       -> nil
      stripped -> stripped
    end
  end

  @spec add_field({String.t, String.t}, map, boolean) :: map
  defp add_field(_msg_field, source_data, false), do: source_data
  defp add_field({key, value}, source_data, true) do
    Map.put(source_data, key, value)
  end
end
