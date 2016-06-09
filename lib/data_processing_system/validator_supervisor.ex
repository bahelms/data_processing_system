defmodule DPS.ValidatorSupervisor do
  use Supervisor

  @worker_count 100

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Creates many validator workers and checks them into a pool.
  """
  def init([]) do
    children = for num <- 0..@worker_count do
      worker(DPS.Validator, [], id: num)
    end

    supervise(children, strategy: :one_for_one)
  end
end
