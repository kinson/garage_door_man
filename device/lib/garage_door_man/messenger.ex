defmodule GarageDoorMan.Messenger do
  def send_data(calibrated, interval_average) do
    body = Jason.encode!(%{calibrated: calibrated, value: interval_average})

    :hackney.post(
      "http://localhost:4000/api/receive_data",
      ["Content-Type": "application/json"],
      body,
      []
    )
  end
end
