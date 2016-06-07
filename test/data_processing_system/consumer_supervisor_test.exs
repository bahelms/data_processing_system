defmodule DPS.ConsumerSupervisorTest do
  use ExUnit.Case, async: true

  test "the number of children is determined by a config file" do
    results = Supervisor.count_children(DPS.ConsumerSupervisor)
    assert results.workers == 3
  end
end
