defmodule DPS.ConsumerSupervisor do
  use Supervisor

  @consumer_config_file "config/consumer_config.yml"

  def start_link do
    {:ok, sup} = Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = for {{table, topic}, index} <- config do
      worker(DPS.Consumer, [topic], id: index)
    end

    supervise(children, strategy: :one_for_one)
  end

  defp config do
    @consumer_config_file
    |> YamlElixir.read_from_file
    |> Enum.with_index
  end
end
