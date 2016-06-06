defmodule DPS.Worker do
  require Logger

  def start_link do
    Task.start_link(__MODULE__, :process, [])
  end

  def process do
    :timer.sleep(2000)
  end
end
