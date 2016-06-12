defmodule Mix.Tasks.StartApp do
  use Mix.Task
  require Logger

  @shortdoc "This starts the Data Processing System application"

  def run(_args) do
    # Wait for DB container to be available
    :timer.sleep(2000)

    # Create DB if it doesn't exist
    Logger.info "Creating database..."
    Mix.Task.run("ecto.create")

    # Setup DB
    Logger.info "Setting up database..."
    Mix.Task.run("setup_database")

    # Start app
    Mix.Task.run("run", ["--no-halt"])
  end
end
