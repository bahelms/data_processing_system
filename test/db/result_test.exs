defmodule DB.ResultTest do
  use ExUnit.Case, async: true

  setup do
    context =
      %{result:
        %Postgrex.Result{
          columns: ["scclgp","sccscl", "scdlcd", "id"],
          command: :select, connection_id: 685, num_rows: 0,
          rows: [["02","123",nil,"id123"], ["03","124","D","id124"]]}}
    {:ok, context}
  end

  test "converting a postgrex result", %{result: result} do
    expected_results = [
      %{scclgp: "02",
        sccscl: "123",
        scdlcd: nil,
        id:     "id123"},
      %{scclgp: "03",
        sccscl: "124",
        scdlcd: "D",
        id:     "id124"},
    ]
    assert DB.Result.convert(result) == expected_results
  end
end
