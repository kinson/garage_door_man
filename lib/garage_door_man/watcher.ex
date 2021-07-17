defmodule GarageDoorMan.Watcher.State do
  @enforce_keys [:sensor_pid]
  defstruct [:sensor_pid, readings: []]
end

defmodule GarageDoorMan.Watcher do
  use GenServer

  require Logger

  alias GarageDoorMan.Watcher.State

  @read_interval :timer.seconds(1)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def gather_sensor_data do
    GenServer.call(__MODULE__, :gather_sensor_data)
  end

  @impl true
  def init(_) do
    {:ok, pid} = Hcsr04.start_link(trigger: 18, echo: 23)

    schedule_read()

    state = %State{sensor_pid: pid}

    {:ok, state}
  end

  @impl true
  def handle_info(:read_sensor, %State{readings: readings, sensor_pid: pid} = state) do
    distance = Hcsr04.read(pid)

    Logger.debug("read sensor: #{distance}")

    new_readings = [distance | readings]

    schedule_read()

    {:noreply, %State{state | readings: new_readings}}
  end

  @impl true
  def handle_call(:gather_sensor_data, _from, %State{readings: readings} = state) do
    avg = Enum.sum(readings) / Enum.count(readings)
    {:reply, avg, %State{state | readings: []}}
  end

  defp schedule_read() do
    Process.send_after(self(), :read_sensor, @read_interval)
  end
end
