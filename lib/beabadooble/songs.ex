defmodule Beabadooble.Songs do
  use GenServer
  alias Beabadooble.Schema
  import Ecto.Query, only: [from: 2]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_state) do
    songs = Beabadooble.Repo.all(from(s in Schema.Songs, select: s.name))
    schedule()
    {:ok, %{songs: songs}}
  end

  def handle_info(:prepare_next, state) do
    schedule()
    {:noreply, state}
  end

  defp schedule() do
    {curr, _} = Time.to_seconds_after_midnight(Time.utc_now())
    # 5 minutes before midnight 
    delay = (86100) - curr
    Process.send_after(self(), :prepare_next, :timer.seconds(delay))
  end

  def handle_call(:all_songs, _from, %{songs: songs} = state), do: {:reply, songs, state}

  def get_all_songs(), do: GenServer.call(__MODULE__, :all_songs)

  def get_today() do
    #today = Date.utc_today()

    %{
      name: "Test",
      idx: 0,
      urls: ["https://download.samplelib.com/mp3/sample-3s.mp3", "https://download.samplelib.com/mp3/sample-9s.mp3", "https://download.samplelib.com/mp3/sample-15s.mp3"]
    }
  end
end
