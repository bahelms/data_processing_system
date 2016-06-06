defmodule DPS.Consumer do
  require Logger

  def start_link(topic) do
    {:ok, task} = Task.start_link(__MODULE__, :consume, [topic])
    Logger.info "Consuming \"#{topic}\" topic."
    {:ok, task}
  end

  @spec consume(String.t) :: any
  def consume(topic) do
    # convert JSON to map
    # give map to worker
    consume(topic)
  end

  @doc """
  Converts incoming JSON payloads to maps
  """
  @spec convert_to_map(nil) :: String.t
  def convert_to_map(nil), do: "No Message"

  @spec convert_to_map(String.t) :: %{String.t => String.t}
  def convert_to_map(json), do: Poison.decode!(json)
end
