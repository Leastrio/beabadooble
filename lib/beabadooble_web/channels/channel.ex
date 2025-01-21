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

    result =
      case socket.assigns.curr_song.parsed_name == cleaned_guess do
        true -> :correct
        false -> :incorrect
      end

    {:reply, {:ok, result}, socket}
  end

  @impl true
  def handle_in("end_game", %{"game_result" => result, "date" => date}, socket) do
    today = Date.to_string(Date.utc_today())

    info =
      case today == date do
        true ->
          BeabadoobleWeb.Endpoint.subscribe("stats_updates")
          info = Songs.get_end_info()
          Songs.update_global_stats(result)
          info

        false ->
          stats =
            cond do
              result in ["win", "loss"] ->
                from(s in Schema.DailySongs,
                  where: s.date == ^date,
                  update: [
                    inc: ^(if result == "win", do: [global_wins: 1], else: [global_losses: 1])
                  ],
                  select: %{wins: s.global_wins, losses: s.global_losses}
                )
                |> Beabadooble.Repo.update_all([])
                |> elem(1)
                |> hd()

              true ->
                %{wins: 0, losses: 0}
            end

          %{stats | name: socket.assigns.curr_song.name}
      end

    {:reply, {:ok, info}, socket}
  end

  @impl true
  def handle_in("set_game", %{"date" => date, "completed" => completed}, socket) do
    today = Date.to_string(Date.utc_today())

    if today == date && completed == true do
      BeabadoobleWeb.Endpoint.subscribe("game_refresh")
      BeabadoobleWeb.Endpoint.subscribe("stats_updates")
    else
      BeabadoobleWeb.Endpoint.unsubscribe("game_refresh")
      BeabadoobleWeb.Endpoint.unsubscribe("stats_updates")
    end

    song =
      cond do
        today == date -> Songs.get_song_info()

        date < today ->
          Repo.get_by(Beabadooble.Schema.DailySongs, date: date)
          |> Repo.preload([:song])
          |> Songs.generate_song_details()

        date > today -> nil
      end

    case song do
      nil ->
        {:reply, {:ok, nil}, socket}

      _ ->
        payload =
          case completed do
            true -> Map.take(song, [:id, :name, :wins, :losses])
            false -> Map.take(song, [:id, :clip_urls])
          end

        {
          :reply,
          {:ok, payload},
          assign(socket, curr_song: Map.take(song, [:id, :parsed_name, :name]))
        }
    end
  end

  @impl true
  def handle_info({:update_stats, result}, socket) do
    push(socket, "stats_update", %{status: result})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:refresh_song, client_info, socket_info}, socket) do
    push(socket, "refresh_song", client_info)
    {:noreply, assign(socket, curr_song: socket_info)}
  end
end
