defmodule Mix.Tasks.SetupDatabase do
  use Mix.Task

  @shortdoc "Sets up DB - essentially the same as running migrations"
  @config_file "config/dps_config.yml"

  def run(_) do
    Application.ensure_all_started(:data_processing_system)
    Mix.shell.info "Creating tables from #{@config_file}..."
    YamlElixir.read_from_file(@config_file)
    |> DB.Utils.create_tables
  end
end
