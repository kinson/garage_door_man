defmodule GarageDoorMan.SensorInterface do
  @moduledoc false

  require Logger

  alias Circuits.I2C

  def open_i2c_bus(bus_name) do
    open_i2c = I2C.open(bus_name)

    Logger.debug(
      "Sensor Interface open I2C bus #{inspect(bus_name)} with result: '#{inspect(open_i2c)}'"
    )

    open_i2c
  end

  def terminate(i2c_ref) do
    close_i2c = I2C.close(i2c_ref)

    Logger.debug(
      "Sensor Interface close I2C bus #{inspect(i2c_ref)} with result: '#{inspect(close_i2c)}'"
    )

    close_i2c
  end

  def read_values(state) do
    {:ok, distance} =
      ADS1115.read(state.i2c_ref, state.i2c_bus_addr, state.sensor_in)

    distance
  end
end
