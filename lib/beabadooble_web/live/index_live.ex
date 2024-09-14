defmodule BeabadoobleWeb.IndexLive do
  use BeabadoobleWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
      <div
        :if={@message}
        id="message-container"
        class="bg-rose-400 p-10 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] shadow-rose-700 mb-6"
        phx-mounted={JS.transition({"animate-pop-in", "opacity-0", "opacity-100"}, time: 500)}
        phx-remove={JS.hide(transition: {"animate-pop-out", "opacity-100", "opacity-0"}, time: 500)}
      >
        <p class="text-center text-white text-2xl font-[Anybody-Black] select-none"><%= @message %></p>
      </div>

      <div :if={@game_state.result in [:won, :lost]} class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6 text-center"> 
        <p :if={@game_state.result == :won} class="text-3xl">Congrats, you won!</p>
        <p :if={@game_state.result == :lost} class="text-3xl">Better luck next time!</p>

        <hr class="border-slate-300 my-2">
        <p class="text-gray-600">Song: <%= @current_song.name %></p> 
        
        <div class="my-4">
          <p class="text-lg font-bold">BEABADOOBLE #<%= @current_song.id %></p>
          <p class="pb-3"><%= select_emojis(@game_state.guesses) %></p>
          <button aria-label="Copy Result" id="copy" phx-hook="Copy" class="bg-gray-200 hover:bg-gray-300 text-gray-800 py-2 px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition duration-200 ease-in-out transform hover:scale-105 active:scale-95">
            <div class="flex items-center">
              <span class="pr-2 text-sm font-bold">COPY</span>
              <.icon name="hero-document-duplicate"/>
            </div>
          </button>
        </div>

        <hr class="border-slate-300 my-2">
        <p class="text-lg font-[RobotoMono]">Next song in</p>
        <p id="countdown" phx-hook="Countdown" class="font-[RobotoMono] text-2xl"></p>
      </div>

      <div :if={@game_state.result == :playing} class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6">
        <datalist id="suggestions" phx-hook="Autocomplete">
          <%= for song <- @songs do %>
            <option value={song}><%= song %></option>
          <% end %>
        </datalist>
        <.intersperse :let={guess} enum={@game_state.guesses}>
          <:separator>
            <hr class="border-slate-300">
          </:separator>
          <%= if guess.status == :current do %>
            <.guess_input name={guess.name} length={guess.length} status={guess.status} placeholder={get_placeholder(guess)} list="suggestions"/>
          <% else %> 
            <.guess_input name={guess.name} length={guess.length} status={guess.status} placeholder={get_placeholder(guess)}/>
          <% end %>
          
        </.intersperse>
      </div>

      <div :if={@game_state.result == :playing} id="audio-player" class="bg-white p-4 mb-6 rounded-2xl shadow-[0.25rem_0.25rem_0_0px]" phx-hook="AudioPlayer">
        <div class="flex justify-between items-center space-x-4">
          <button aria-label="Play Audio" id="play" class="bg-[#71c0d6] hover:bg-[#3497b2] text-white font-bold py-2 px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition duration-200 ease-in-out transform hover:scale-105 hover:rotate-12 active:scale-95">
            <.icon name="hero-play" class="w-8 h-8 aspect-square"/>
          </button>
          <div class="w-full bg-gray-200 rounded-full h-5 overflow-hidden">
            <div id="progress" class="bg-[#71c0d6] h-5 rounded-full w-0"></div>
          </div>
          <form phx-submit="skip">
            <button aria-label="Skip Audio" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition duration-200 ease-in-out transform hover:scale-105 hover:-rotate-12 active:scale-95">
              <.icon name="hero-forward" class="w-8 h-8 aspect-square" />
            </button>
          </form>
        </div>
      </div>
    """
  end
  
  @impl true
  def mount(_params, _session, socket) do
    game = case get_connect_params(socket) do
      nil -> %{Beabadooble.GameState.new() | result: nil}
      %{"restore" => nil} -> Beabadooble.GameState.new()
      %{"restore" => game_state} -> Beabadooble.GameState.restore(game_state) 
    end

    curr_song = Beabadooble.Songs.get_today()

    socket = socket
    |> assign(
      songs: Beabadooble.Songs.get_all_songs(),
      message: nil,
      timer: nil,
      game_state: game,
      current_song: curr_song
    )
    |> push_event("session:set_audio", %{url: Enum.at(curr_song.urls, game.song_idx)})

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
    |> seek_song()
    |> store_session()

    {:noreply, socket}
  end

  @impl true
  def handle_info(:clear_message, socket) do
    {:noreply, socket |> assign(message: nil, timer: nil)}
  end

  defp seek_song(socket) do
    old_state = socket.assigns.game_state
    new_state = %{old_state | song_idx: old_state.song_idx + 1}

    socket
    |> assign(game_state: new_state)
    |> push_event("session:set_audio", %{url: Enum.at(socket.assigns.current_song.urls, new_state.song_idx)})
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
    |> seek_song()
    |> store_session()
  end

  defp select_emojis(guesses, emojis \\ "")
  defp select_emojis([], emojis), do: emojis
  defp select_emojis([%{status: status} | rest], emojis) do
    heart = case status do
      :correct -> "💚"
      :incorrect -> "❤️"
      :empty -> "🖤"
      :current -> "🖤"
      _ -> "🩶"
    end

    select_emojis(rest, emojis <> heart)
  end

  defp store_session(socket) do
    json_dump = to_string(:json.encode(socket.assigns.game_state))
    push_event(socket, "session:store", %{key: "beabadooble", val: json_dump})
  end
end
