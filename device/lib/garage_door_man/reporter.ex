defmodule GarageDoorMan.Reporter do
  use GenServer

  require Logger

  defstruct [:averages, :callibrated_value]

  @gather_interval :timer.seconds(30)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def set_callibrated_value(value) do
    GenServer.cast(GarageDoorMan.Reporter, {:set_callibrated_value, value})
  end

  @impl true
  def init(_) do
    schedule_gather()

    state = %GarageDoorMan.Reporter{averages: [], callibrated_value: nil}

    {:ok, state}
  end

  @impl true
  def handle_cast({:set_callibrated_value, value}, state) do
    Logger.debug("Setting calibrated value: #{value}")
    {:noreply, %{state | callibrated_value: value}}
  end

  @impl true
  def handle_info(:gather_sensor_data, %{callibrated_value: nil} = state) do
    schedule_gather()

    {:noreply, state}
  end

  def handle_info(:gather_sensor_data, %GarageDoorMan.Reporter{callibrated_value: callibrated_value} = state) do
    readings = GarageDoorMan.Watcher.gather_sensor_data()

    average = Enum.sum(readings) / Enum.count(readings)

    Logger.debug("Average range reading: #{average}")

    send_data(average, callibrated_value)

    schedule_gather()

    {:noreply, state}
  end

  def send_data(average, callibrated) do
    case GarageDoorMan.Messenger.send_data(average, callibrated) do
      {:error, _} -> Logger.warn("Failed to send data to host")
      _ -> Logger.debug("Sent data to host :metal:")
    end
  end

  defp schedule_gather() do
    Process.send_after(self(), :gather_sensor_data, @gather_interval)
  end
end
