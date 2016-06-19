defmodule DB.Result do
  @moduledoc """
  Helper functions for working with %Postgrex.Result{}
  """

  @doc """
  Converts a %Postgrex.Result{} into a map
  """
  @spec convert(%Postgrex.Result{}) :: [%{atom => String.t}] | []
  def convert(result) do
    Enum.map result.rows, fn(row) ->
      result.columns
      |> Enum.map(&String.to_atom/1)
      |> Enum.zip(row)
      |> Enum.into(%{})
    end
  end
end
