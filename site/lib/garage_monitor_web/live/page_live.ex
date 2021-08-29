defmodule GarageMonitorWeb.PageLive do
  use GarageMonitorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    data = GarageMonitor.CoatClosetServer.retrieve()
    {:ok, assign(socket, data: data)}
  end
end
