defmodule GarageMonitor.CoatClosetServer do
  use GenServer

  @table :sensor_data

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(@table, [
      :set,
      :named_table,
      read_concurrency: true
    ])

    {:ok, %{}}
  end

  def store(callibrated, interval_average) do
    # accept callibrated value, average value and store it
    GenServer.call(__MODULE__, {:store_data, callibrated, interval_average})
  end

  def retrieve() do
    # return all of the data
    GenServer.call(__MODULE__, :retrieve_data)
  end

  @impl true
  def handle_call({:store_data, callibrated, interval_average}, _from, state) do
    dt = DateTime.utc_now()

    new_sample = {dt, callibrated, interval_average}
    key = "data-#{DateTime.to_unix(dt)}" |> String.to_atom()
    result = :ets.insert(@table, {key, new_sample})

    {:reply, result, state}
  end

  def handle_call(:retrieve_data, _from, state) do
    data = :ets.tab2list(@table)

    data =
      data
      |> Enum.map(fn {_, data} -> data end)
      |> Enum.sort(&compare_dates/2)
      |> Enum.take(20)

    {:reply, data, state}
  end

  defp compare_dates({da, _, _}, {db, _, _}) do
    DateTime.compare(da, db) == :gt
  end
end
