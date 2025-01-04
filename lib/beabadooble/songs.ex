defmodule Beabadooble.Songs do
  use GenServer
  alias Beabadooble.Schema
  import Ecto.Query, only: [from: 2]
  require Logger

  defstruct [:songs, :today_song]

  @base_url "https://cdn.beabadooble.com"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_state) do
    songs = Beabadooble.Repo.all(from(s in Schema.Songs, select: s.name))
    today = Date.utc_today()

    current_song =
      Beabadooble.Repo.one(from(s in Schema.DailySongs, where: s.date == ^today, preload: :song))
      |> generate_song_details()

    {curr_time, _} = Time.utc_now() |> Time.to_seconds_after_midnight()
    schedule(curr_time)

    case current_song do
      nil -> {:ok, %__MODULE__{songs: songs}, {:continue, {:prepare_today, today}}}
      _ -> {:ok, %__MODULE__{songs: songs, today_song: current_song}}
    end
  end

  def handle_continue({:prepare_today, today}, state) do
    Logger.info("Song for today not found! Preparing clips...")
    daily_song = prepare_clips(today) |> generate_song_details()
    {:noreply, %__MODULE__{state | today_song: daily_song}}
  end

  def handle_info(:prepare_next, state) do
    Logger.info("Preparing tomorrows song...")

    tomorrow = Date.utc_today() |> Date.add(1)

    tomorrow_song =
      case Beabadooble.Repo.one(
             from(s in Schema.DailySongs, where: s.date == ^tomorrow, preload: :song)
           ) do
        nil -> prepare_clips(tomorrow)
        song -> song
      end
      |> generate_song_details()

    {curr_time, _} = Time.to_seconds_after_midnight(Time.utc_now())

    Process.send_after(
      self(),
      {:cache_new_song, tomorrow_song},
      :timer.seconds(86400 - curr_time)
    )

    schedule(curr_time)
    {:noreply, state}
  end

  def handle_info({:cache_new_song, song}, state) do
    Phoenix.PubSub.broadcast(
      Beabadooble.PubSub,
      "game_refresh",
      {:refresh_song, Map.take(song, [:id, :clip_urls]),
       Map.take(song, [:id, :parsed_name, :name, :wins, :losses])}
    )

    {:noreply, %__MODULE__{state | today_song: song}}
  end

  def handle_cast(:increment_wins, %{today_song: song} = state) do
    query = from(s in Schema.DailySongs, where: s.id == ^song.id, update: [inc: [global_wins: 1]])

    case Beabadooble.Repo.update_all(query, []) do
      {1, _} -> {:noreply, %{state | today_song: %{song | wins: song.wins + 1}}}
      _ -> {:noreply, state}
    end
  end

  def handle_cast(:increment_losses, %{today_song: song} = state) do
    query =
      from(s in Schema.DailySongs, where: s.id == ^song.id, update: [inc: [global_losses: 1]])

    case Beabadooble.Repo.update_all(query, []) do
      {1, _} -> {:noreply, %{state | today_song: %{song | losses: song.losses + 1}}}
      _ -> {:noreply, state}
    end
  end

  def handle_call(:get_connect_state, _from, %{songs: songs, today_song: %{id: id}} = state),
    do: {:reply, {songs, id}, state}

  def handle_call(:get_song_info, _from, %{today_song: song} = state),
    do: {:reply, song, state}

  def handle_call(
        :get_end_info,
        _from,
        %{today_song: %{name: name, wins: wins, losses: losses}} = state
      ),
      do: {:reply, %{name: name, wins: wins, losses: losses}, state}

  defp choose_song(songs, cutoff_date) do
    song = Enum.random(songs)
    start_time = Enum.random(10..(song.seconds - 15))

    if Beabadooble.Repo.exists?(
         from s in Schema.DailySongs,
           where: s.song_id == ^song.id and (s.start_time == ^start_time or s.date > ^cutoff_date)
       ) do
      choose_song(songs, cutoff_date)
    else
      {song, start_time}
    end
  end

  defp prepare_clips(date) do
    cutoff_date = date |> Date.add(-30) |> Date.to_string()
    songs = Beabadooble.Repo.all(Schema.Songs)
    {chosen_song, start_time} = choose_song(songs, cutoff_date)
    song_path = Path.join(:code.priv_dir(:beabadooble) ++ ~c'/audio/', chosen_song.filename)
    r2_host = Application.get_env(:beabadooble, :r2_host)

    {:ok, daily_song} =
      Beabadooble.Repo.transaction(fn ->
        upload_file(r2_host, start_time, "0.5", song_path, date, "1")
        upload_file(r2_host, start_time, "1", song_path, date, "2")
        upload_file(r2_host, start_time, "2.5", song_path, date, "3")

        %Schema.DailySongs{
          date: date,
          song_id: chosen_song.id,
          start_time: start_time,
          global_wins: 0,
          global_losses: 0
        }
        |> Beabadooble.Repo.insert!()
      end)

    Beabadooble.Repo.preload(daily_song, :song)
  end

  defp upload_file(host, start_time, clip_length, song_path, tomorrow, name) do
    {audio_clip, 0} =
      System.cmd("ffmpeg", [
        "-ss",
        "#{start_time}",
        "-t",
        clip_length,
        "-i",
        "#{song_path}",
        "-map_metadata",
        "-1",
        "-f",
        "mp3",
        "pipe:1"
      ])

    ExAws.S3.put_object(
      "beabadooble",
      "#{tomorrow.year}/#{tomorrow.month}/#{tomorrow.day}/#{name}.mp3",
      audio_clip
    )
    |> ExAws.request!(host: host)
  end

  defp schedule(curr_time) do
    # 5 min before midnight
    delay =
      if curr_time > 86100 do
        86400 - curr_time + 86100
      else
        86100 - curr_time
      end

    Process.send_after(self(), :prepare_next, :timer.seconds(delay))
  end

  def get_connect_state(), do: GenServer.call(__MODULE__, :get_connect_state)
  def get_song_info(), do: GenServer.call(__MODULE__, :get_song_info)
  def get_end_info(), do: GenServer.call(__MODULE__, :get_end_info)

  def generate_song_details(nil), do: nil

  def generate_song_details(song) do
    %{date: date, id: id, song: %{name: song_name}, global_wins: wins, global_losses: losses} =
      song

    url = "#{@base_url}/#{date.year}/#{date.month}/#{date.day}"

    parsed_name = song_name |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")

    %{
      name: song_name,
      parsed_name: parsed_name,
      id: id,
      wins: wins,
      losses: losses,
      clip_urls: [
        url <> "/1.mp3",
        url <> "/2.mp3",
        url <> "/3.mp3"
      ]
    }
  end

  def update_global_stats(result) do
    case result do
      "win" -> GenServer.cast(__MODULE__, :increment_wins)
      "loss" -> GenServer.cast(__MODULE__, :increment_losses)
      _ -> :ok
    end

    if result in ["win", "loss"] do
      Phoenix.PubSub.broadcast(Beabadooble.PubSub, "stats_updates", {:update_stats, result})
    end
  end
end
