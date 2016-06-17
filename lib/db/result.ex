defmodule DB.Result do
  @moduledoc """
  Helper functions for working with %Postgrex.Result{}
  """

  @doc """
  Converts a %Postgrex.Result{} into a map
  """
  @spec convert(%Postgrex.Result{}) :: %{String.t => String.t}
  def convert(result) do
    result.rows
    |> Enum.map(fn(row) ->
      Enum.zip(result.columns, row)
        |> Enum.into(%{})
    end)
  end
end
