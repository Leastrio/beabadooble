defmodule BeabadoobleWeb.IndexLive do
  use BeabadoobleWeb, :live_view
  import BeabadoobleWeb.GameComponents
  alias Beabadooble.{GameState, Stats}

  @impl true
  def render(assigns) do
    ~H"""
      <.info_modal id="info-modal" />
      <.stats_modal id="stats-modal" stats={@stats}/>
      <div
        :if={@message}
        id="message-container"
        class="bg-rose-400 p-10 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] shadow-rose-700 mb-6"
        phx-mounted={JS.transition("animate-pop-in", time: 500)}
        phx-remove={JS.hide(transition: "animate-pop-out", time: 500)}
      >
        <p class="text-center text-white text-2xl font-[Anybody-Black] select-none"><%= @message %></p>
      </div>

      <.game_end :if={@game_state.result in [:won, :lost]} game_state={@game_state} current_song={@current_song} />

      <%= if @game_state.result == :playing do %>
        <div id="Autocomplete" class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6" phx-hook="Autocomplete">
          <.intersperse :let={guess} enum={@game_state.guesses}>
            <:separator>
              <hr class="border-slate-300">
            </:separator>
            <.guess_input name={guess.name} length={guess.length} status={guess.status} placeholder={get_placeholder(guess)}/>
          </.intersperse>
        </div>

        <.audio_player game_state={@game_state} />
      <% end %>
      
      <div :if={not is_nil(@game_state.result)} class="flex justify-end space-x-3 mb-6">
        <button phx-click={show_modal("stats-modal")} class="bg-white p-3 rounded-2xl shadow-[0.25rem_0.25rem_0_0px]">
          <.icon name="hero-chart-bar" class="size-8"/>
        </button>
        <button phx-click={show_modal("info-modal")} class="bg-white p-3 rounded-2xl shadow-[0.25rem_0.25rem_0_0px]">
          <.icon name="hero-information-circle" class="size-8"/>
        </button>
      </div>

    """
  end
  
  @impl true
  def mount(_params, _session, socket) do
    {game, stats} = case get_connect_params(socket) do
      nil -> {%{GameState.new() | result: nil}, Stats.new()}
      %{"restore" => nil} -> {GameState.new(), Stats.new()}
      %{"restore" => %{"stats" => stats, "game_state" => game_state}} -> {GameState.restore(game_state), Stats.restore(stats)}
    end

    curr_song = Beabadooble.Songs.get_today()

    socket = socket
    |> assign(
      message: nil,
      timer: nil,
      game_state: game,
      stats: stats,
      current_song: curr_song
    )
    |> push_event("session:preload_audio", %{urls: curr_song.urls, curr_idx: game.song_idx})
    |> maybe_send_autocomplete_data()

    if connected?(socket) do
      BeabadoobleWeb.Endpoint.subscribe("game_updates")
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", params, socket) do
    [{name, input}] = Map.to_list(params)
    socket = case input do
      "" -> handle_empty_input(socket)
      _ -> handle_guess({name, input}, socket)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("skip", _params, socket) do
    state = socket.assigns.game_state
    {guesses, acc} = Enum.map_reduce(state.guesses, false,
      fn 
        g, false -> 
          if g.status == :current do
            {%{g | status: :skipped}, true}
          else
            {g, false}
          end
        g, true -> 
          {%{g | status: :current}, false}
      end)

    result = if acc == true do
      :lost 
    else
      :playing
    end

    socket = socket
    |> assign(game_state: %{state | guesses: guesses, result: result})
    |> update_stats()
    |> seek_song()
    |> store_history()

    {:noreply, socket}
  end

  @impl true
  def handle_info(:clear_message, socket) do
    {:noreply, socket |> assign(message: nil, timer: nil)}
  end

  @impl true
  def handle_info({:refresh_song, new_song}, socket) do
    new_game = GameState.new()
    socket = socket
    |> assign(current_song: new_song, game_state: new_game)
    |> push_event("session:preload_audio", %{urls: new_song.urls, curr_idx: new_game.song_idx})
    |> maybe_send_autocomplete_data()

    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_stats, result}, socket) do
    current_song = socket.assigns.current_song

    upd_song = case result do
        :won -> %{current_song | wins: current_song.wins + 1}
        :lost -> %{current_song | losses: current_song.losses + 1}
    end

    {:noreply, assign(socket, current_song: upd_song)}
  end
  
  defp seek_song(socket) do
    old_state = socket.assigns.game_state
    new_state = %{old_state | song_idx: old_state.song_idx + 1}

    socket
    |> assign(game_state: new_state)
    |> push_event("session:next_audio", %{})
  end

  defp put_message(socket, msg) do
    if not is_nil(socket.assigns.timer) do
      Process.cancel_timer(socket.assigns.timer)
    end
    timer_ref = Process.send_after(self(), :clear_message, 2500)
    assign(socket, message: msg, timer: timer_ref)
  end

  defp get_placeholder(%{status: status, input: input}) do
    case status do
      :empty -> ""
      :skipped -> "Skipped"
      _ -> input
    end
  end

  defp handle_empty_input(socket), do: put_message(socket, "Please enter a guess!")

  defp handle_guess({input_name, guess}, socket) do
    cleaned_guess = guess |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")
    state = socket.assigns.game_state

    status = if cleaned_guess == socket.assigns.current_song.parsed_name do
      :correct  
    else
      :incorrect
    end

    result = cond do
      status == :correct -> :won
      input_name == "guess_three" -> :lost
      true -> :playing
    end

    {guesses, _acc} = Enum.map_reduce(state.guesses, false,
      fn 
        g, false -> 
          if input_name == g.name do
            {%{g | status: status, input: guess}, true}
          else
            {g, false}
          end
        g, true -> 
          {%{g | status: :current}, false}
      end)

    socket
    |> assign(game_state: %{state | guesses: guesses, result: result})
    |> update_stats()
    |> seek_song()
    |> store_history()
  end

  defp update_stats(socket) do
    stats = socket.assigns.stats
    result = socket.assigns.game_state.result
    upd_stats = case result do
      :won -> %Stats{stats | won: stats.won + 1}
      :lost -> %Stats{stats | lost: stats.lost + 1}
      _ -> stats
    end

    socket = assign(socket, stats: upd_stats)
    if result in [:won, :lost] do
      Beabadooble.Songs.update_global_stats(result)
      json_dump = upd_stats |> :json.encode() |> to_string()

      socket
      |> push_event("session:update_stats", %{stats: json_dump})
    else
      socket
    end
  end

  defp store_history(socket) do
    json_dump = socket.assigns.game_state
    |> Map.put_new(:song_id, socket.assigns.current_song.id)
    |> :json.encode()
    |> to_string()

    push_event(socket, "session:store_history", %{data: json_dump})
  end

  defp maybe_send_autocomplete_data(socket) do
    if socket.assigns.game_state.result == :playing do
      push_event(socket, "session:autocomplete_data", %{data: Beabadooble.Songs.get_all_songs()})
    else
      socket
    end
  end
end
