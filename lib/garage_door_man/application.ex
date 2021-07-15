defmodule GarageDoorMan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @sleep_duration 1000

  def start(_type, _args) do
    Logger.debug("~~WELCOME TO GARAGE DOOR MAN~~")

    spawn(&check_distance_forever/0)
  end

  defp check_distance_forever() do
    {:ok, pid} = Hcsr04.start_link(trigger: 18, echo: 23)

    check_distance_loop(pid)
  end

  def check_distance_loop(pid) do
    distance = Hcsr04.read(pid)
    Logger.debug("~~~measured distance: #{distance}")

    :timer.sleep(@sleep_duration)
    check_distance_loop(pid)
  end

  def target() do
    Application.get_env(:garage_door_man, :target)
  end
end
