defmodule GarageDoorMan.Callibrator do
  use GenServer

  require Logger

  @callibration_interval :timer.seconds(30)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    state = %{}
    {:ok, state, {:continue, :start_callibration}}
  end

  @impl true
  def handle_continue(:start_callibration, state) do
    schedule_read()

    {:noreply, state}
  end

  @impl true
  def handle_info(:get_sensor_reading, state) do
    Logger.debug("Getting samples for callibration")

    readings = GarageDoorMan.Watcher.gather_sensor_data()

    number_of_readings = Enum.count(readings)

    refined_readings =
      readings
      |> Enum.sort()
      |> Enum.slice(3, number_of_readings - 3)

    average = Enum.sum(refined_readings) / Enum.count(refined_readings)

    GarageDoorMan.Reporter.set_callibrated_value(average)

    {:noreply, state}
  end

  defp schedule_read() do
    Process.send_after(self(), :get_sensor_reading, @callibration_interval)
  end
end
