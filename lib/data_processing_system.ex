defmodule DPS do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(DPS.ConsumerSupervisor, []),
      # supervisor(DPS.WorkerSupervisor, [])
    ]

    opts = [strategy: :one_for_one, name: DPS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
