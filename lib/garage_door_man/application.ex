defmodule GarageDoorMan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @sleep_duration 1000

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GarageDoorMan.Supervisor]

    Logger.debug("~~WELCOME TO GARAGE DOOR MAN~~")

    children =
      [
        # Children for all targets
        # Starts a worker by calling: GarageDoorMan.Worker.start_link(arg)
        # {GarageDoorMan.Worker, arg},
      ] ++ children(target())

    spawn(&check_distance_forever/0)

    Supervisor.start_link(children, opts)
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

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: GarageDoorMan.Worker.start_link(arg)
      # {GarageDoorMan.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: GarageDoorMan.Worker.start_link(arg)
      # {GarageDoorMan.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:garage_door_man, :target)
  end
end
