defmodule DPS.ValidatorSupervisor do
  use Supervisor

  @worker_count 100

  def start_link(config) do
    Supervisor.start_link(__MODULE__, config, name: __MODULE__)
  end

  @doc """
  Creates many validator workers and checks them into a pool.
  """
  def init(config) do
    cache = DPS.ValidationCache.new_table(:cache)
    children = for num <- 0..@worker_count do
      worker(DPS.Validator, [cache, config], id: num)
    end

    supervise(children, strategy: :one_for_one)
  end
end
