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
