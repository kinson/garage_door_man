defmodule GarageMonitorWeb.SensorDataController do
  use GarageMonitorWeb, :controller

  def create(conn, %{"calibrated" => calibrated, "value" => value}) do
    GarageMonitor.CoatClosetServer.store(calibrated, value)
    put_status(conn, 201) |> text("Okay")
  end
end
