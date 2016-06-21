defmodule DPS do
  use Application

  @type config :: %{String.t => String.t}

  @dps_config "config/dps_config.yml"

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    config = YamlElixir.read_from_file(@dps_config)

    children = [
      supervisor(DPS.ValidatorSupervisor, [config]),
      supervisor(Task.Supervisor, [[name: DPS.TransformerSupervisor]], id: 1),
      supervisor(Task.Supervisor, [[name: DPS.PersisterSupervisor]], id: 2),
      worker(DPS.Repo, [])
    ]

    opts = [strategy: :one_for_one, name: DPS.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
