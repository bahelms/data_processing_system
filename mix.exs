defmodule DPS.Mixfile do
  use Mix.Project

  def project do
    [app: :data_processing_system,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [mod: {DPS, []},
     applications: [:ecto, :logger, :poolboy, :postgrex, :timex, :yaml_elixir]]
  end

  defp deps do
    [{:ecto, "2.0.0-rc.5"},
     {:poison, "2.1.0"},
     {:poolboy, "1.5.1"},
     {:postgrex, "0.11.1"},
     {:timex, "2.1.6"},
     {:yamerl, github: "yakaz/yamerl"},
     {:yaml_elixir, "1.2.0"}]
  end
end
