defmodule GarageDoorMan.Reporter do
  use GenServer

  require Logger

  @gather_interval :timer.seconds(30)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_gather()

    {:ok, []}
  end

  @impl true
  def handle_info(:gather_sensor_data, state) do
    average = GarageDoorMan.Watcher.gather_sensor_data()

    Logger.debug("Average range reading: #{average}")

    schedule_gather()

    {:noreply, [{DateTime.utc_now(), average} | state]}
  end

  defp schedule_gather() do
    Process.send_after(self(), :gather_sensor_data, @gather_interval)
  end
end
