defmodule DPS.SimpleMessageBroker do
  @moduledoc """
  A temporary, stand-in broker used to help get the system up and running
  """

  @static_messages_count 10
  @current_topics ["ivmast_topic", "sycgroup_topic"]

  ## Client ##

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec fetch([topic: String.t]) :: String.t
  def fetch(topic: topic) do
    GenServer.call(__MODULE__, {:fetch, topic})
  end

  ## Server ##

  @doc """
  Setup initial state
  """
  def init([]) do
    {:ok, messages}
  end

  @doc """
  Remove a message from the queue and return it
  """
  def handle_call({:fetch, topic}, _from, state) do
    {msg, msgs} = extract_message(state[topic])
    {:reply, msg, Map.put(state, topic, msgs)}
  end

  defp extract_message([]), do: {nil, []}

  @spec extract_message([String.t]) :: {String.t, [String.t]}
  defp extract_message(messages) do
    [msg | remaining_msgs] = messages
    {msg, remaining_msgs}
  end

  @spec messages :: %{String.t => [String.t]}
  defp messages do
    Enum.reduce @current_topics, %{}, fn(topic, broker_data) ->
      [table | _] = String.split(topic, "_")
      msgs = Enum.map(0..@static_messages_count, &(generate_json(&1, table)))
      Map.put(broker_data, topic, msgs)
    end
  end

  @spec generate_json(integer, String.t) :: String.t
  defp generate_json(num, table) do
    Poison.encode!(%{table: table, ivitem: "X#{num}Z", record_catalog: "ABC"})
  end
end
