defmodule DPS.Persister do
  @moduledoc """
  This module converts maps into SQL inserts/updates and executes them.
  """

  @spec process(map, map) :: {:ok, pid}
  def process(source, public) do
    DPS.PersisterSupervisor
    |> Task.Supervisor.start_child(__MODULE__, :handle_data, [[source, public]])
  end

  @spec handle_data([tuple]) :: any
  def handle_data(table_data) do
    IO.inspect table_data
    table_data
    |> Enum.map(fn({table, data}) ->
      "INSERT INTO #{table} (#{fields(data)}) VALUES (#{values(data)})"
      |> DB.execute_query
    end)
  end

  @spec fields(map) :: String.t
  defp fields(data) do
    Map.keys(data)
    |> Enum.join(",")
  end

  @spec values(map) :: String.t
  defp values(data) do
    data
    |> Map.values
    |> Enum.map(fn(value) -> "'#{value}'" end)
    |> Enum.join(",")
  end
end
