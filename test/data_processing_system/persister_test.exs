defmodule DPS.PersisterTest do
  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(DPS.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(DPS.Repo, {:shared, self})
    source =
      {"sycgroup",
       %{"sgclgp"           => "02",
         "sggpds"           => "desc",
         "record_catalog"   => "ABC",
         "record_timestamp" => "2015-10-23T14:17:46.339713"}}
    public =
      {"customer_groups",
       %{"code"        => "02",
         "description" => "desc",
         "division"    => "ABC"}}
    {:ok, [source: source, public: public]}
  end

  test "processing source and public as inserts", context do
     DPS.Persister.process(context.source, context.public)

     :timer.sleep(50)
     [sycgroup] = DB.select_all("sycgroup", sgclgp: "02")
     [group]    = DB.select_all("customer_groups", code: "02")

     assert sycgroup.sggpds == "desc"
     assert group.division  == "ABC"
  end
end
