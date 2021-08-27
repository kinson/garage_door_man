defmodule GarageMonitor.CoatClosetServer do
  use GenServer

  def start_link(_) do
    GenServer.start_linK(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end
end
