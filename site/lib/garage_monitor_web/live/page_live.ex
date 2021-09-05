defmodule GarageMonitorWeb.PageLive do
  use GarageMonitorWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    data = GarageMonitor.CoatClosetServer.retrieve()
    {:ok, assign(socket, data: data)}
  end

  def date_label(%DateTime{} = dt) do
    "#{dt.month}/#{dt.day} #{dt.hour}:#{dt.minute}"
  end

  def background_color(val, callibrated) do
    ratio = val / callibrated * 100
    ratio = Float.round(ratio)
    deviation = abs(ratio - 100)

    if deviation > 10 do
      "bg-red-200"
    else
      "bg-green-200"
    end
  end
end
