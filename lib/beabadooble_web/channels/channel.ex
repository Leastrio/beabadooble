defmodule BeabadoobleWeb.Channel do
  use BeabadoobleWeb, :channel

  @impl true
  def join("beabadooble:session", _payload, socket) do
    BeabadoobleWeb.Endpoint.subscribe("game_refresh")
    %{songs: songs, today_song: today} = Beabadooble.Songs.get_state()
    {:ok, %{song_list: songs, today: Map.take(today, [:id, :clip_urls])}, socket}
  end

  @impl true
  def handle_in("submit_guess", %{"input" => input}, socket) do
    parsed_name = Beabadooble.Songs.get_parsed_name()
    cleaned_guess = input |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")
    result = case parsed_name == cleaned_guess do
      true -> :correct
      false -> :incorrect
    end
    {:reply, {:ok, result}, socket}
  end

  @impl true
  def handle_in("end_game", %{"game_result" => result}, socket) do
    BeabadoobleWeb.Endpoint.subscribe("stats_updates")
    info = Beabadooble.Songs.get_end_info()
    Beabadooble.Songs.update_global_stats(result)
    {:reply, {:ok, info}, socket}
  end

  @impl true
  def handle_in("end_game", payload, socket) when payload == %{} do
    BeabadoobleWeb.Endpoint.subscribe("stats_updates")
    {:reply, {:ok, Beabadooble.Songs.get_end_info()}, socket}
  end

  @impl true
  def handle_info({:update_stats, result}, socket) do
    push(socket, "stats_update", %{status: result})
    {:noreply, socket}
  end

  @impl true
  def handle_info({:refresh_song, song}, socket) do
    push(socket, "refresh_song", Map.take(song, [:id, :clip_urls]))
    {:noreply, socket}
  end
end
