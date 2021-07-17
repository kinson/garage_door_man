defmodule GarageDoorMan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    Logger.debug("~~WELCOME TO GARAGE DOOR MAN~~")

    opts = [strategy: :one_for_one, name: GarageDoorMan.Supervisor]

    children = [
      GarageDoorMan.Watcher,
      GarageDoorMan.Reporter
    ]

    Supervisor.start_link(children, opts)
  end

  def target() do
    Application.get_env(:garage_door_man, :target)
  end
end
