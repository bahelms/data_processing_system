defmodule Mix.Tasks.StartApp do
  use Mix.Task
  require Logger

  @shortdoc "This starts the Data Processing System application"

  def run(_) do
    Logger.info "Creating Database..."
    Mix.Task.run("ecto.create")
    Mix.Task.run("run", ["--no-halt"])
  end
end
