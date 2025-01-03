defmodule BeabadoobleWeb.Channel do
  use BeabadoobleWeb, :channel
  alias Beabadooble.Repo
  alias Beabadooble.Songs
  alias Beabadooble.Schema
  import Ecto.Query, only: [from: 2]


  @impl true
  def join("beabadooble:session", _payload, socket) do
    {songs, id} = Songs.get_connect_state()
    {:ok, %{song_list: songs, latest_id: id}, socket}
  end

  @impl true
  def handle_in("submit_guess", %{"input" => input}, socket) do
    cleaned_guess = input |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")
    result = case socket.assigns.curr_song.parsed_name == cleaned_guess do
      true -> :correct
      false -> :incorrect
    end
    {:reply, {:ok, result}, socket}
  end

  @impl true
  def handle_in("end_game", %{"game_result" => result, "date" => date}, socket) do
    today = Date.to_string(Date.utc_today())
    info = case today == date do
      true -> 
        BeabadoobleWeb.Endpoint.subscribe("stats_updates")
        info = Songs.get_end_info()
        Songs.update_global_stats(result)
        info
      false ->
        query = case result do
          "win" -> from(s in Schema.DailySongs, where: s.date == ^date, update: [inc: [global_wins: 1]])
          "loss" -> from(s in Schema.DailySongs, where: s.date == ^date, update: [inc: [global_losses: 1]])
          _ -> nil
        end
        
        if not is_nil(query) do
          Beabadooble.Repo.update_all(query, [])
        end

        song_info = Map.take(socket.assigns.curr_song, [:name, :wins, :losses])
        case result do
          "win" -> Map.update!(song_info, :wins, &(&1 + 1))
          "loss" -> Map.update!(song_info, :losses, &(&1 + 1))
          _ -> song_info
        end
    end

    {:reply, {:ok, info}, socket}
  end

  @impl true
  def handle_in("end_game", %{"date" => date} = payload, socket) when not is_map_key(payload, "game_result") do
    today = Date.to_string(Date.utc_today())
    info = case today == date do
      true -> 
        BeabadoobleWeb.Endpoint.subscribe("stats_updates")
        Songs.get_end_info()
      false -> 
        Map.take(socket.assigns.curr_song, [:name, :wins, :losses])
    end
    {:reply, {:ok, info}, socket}
  end

  @impl true
  def handle_in("set_game", %{"date" => date}, socket) do
    BeabadoobleWeb.Endpoint.unsubscribe("stats_updates")
    today = Date.to_string(Date.utc_today())
    song = cond do
      today == date -> 
        BeabadoobleWeb.Endpoint.subscribe("game_refresh")
        Songs.get_song_info()
      date < today -> 
        BeabadoobleWeb.Endpoint.unsubscribe("game_refresh")
        Repo.get_by(Beabadooble.Schema.DailySongs, date: date)
        |> Repo.preload([:song])
        |> Songs.generate_song_details()
      date > today -> 
        BeabadoobleWeb.Endpoint.unsubscribe("game_refresh")
        nil
    end

    case song do
      nil -> {:reply, {:ok, nil}, socket}
      _ -> 
        {
          :reply, 
          {:ok, Map.take(song, [:id, :clip_urls])}, 
          assign(socket, curr_song: Map.take(song, [:id, :parsed_name, :name, :wins, :losses]))
        }
    end
  end

  @impl true
  def handle_info({:update_stats, result}, socket) do
    push(socket, "stats_update", %{status: result})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:refresh_song, song}, socket) do
    push(socket, "refresh_song", song)
    {:noreply, socket}
  end
end
