defmodule GarageDoorMan.Watcher.State do
  @enforce_keys [:i2c_bus_name, :i2c_bus_addr, :sensor_in]
  defstruct [:i2c_bus_name, :i2c_bus_addr, :sensor_in, :i2c_ref, i2c_bus_gain: 6144, readings: []]
end

defmodule GarageDoorMan.Watcher do
  use GenServer

  require Logger

  alias GarageDoorMan.Watcher.State

  @read_interval :timer.seconds(1)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def gather_sensor_data do
    GenServer.call(__MODULE__, :gather_sensor_data)
  end

  @impl true
  def init(args) do
    schedule_read()

    state = %State{
      i2c_bus_name: Keyword.get(args, :i2c_bus_name),
      i2c_bus_addr: Keyword.get(args, :i2c_bus_addr),
      sensor_in: Keyword.get(args, :sensor_in)
    }

    conn = %{i2c_ref: open_i2c_bus(state.i2c_bus_name)}

    {:ok, Map.merge(state, conn)}
  end

  @impl true
  def handle_info(:read_sensor, %State{readings: readings} = state) do
    distance = GarageDoorMan.SensorInterface.read_values(state)

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

  @impl true
  def terminate(reason, state) do
    GarageDoorMan.SensorInterface.terminate(state.i2c_ref)

    Logger.debug(
      "Sensor Interface terminate: reason='#{inspect(reason)}', state='#{inspect(state)}'"
    )

    state
  end

  defp schedule_read() do
    Process.send_after(self(), :read_sensor, @read_interval)
  end

  defp open_i2c_bus(bus_name) do
    {:ok, i2c_ref} = GarageDoorMan.SensorInterface.open_i2c_bus(bus_name)
    i2c_ref
  end
end
