defmodule BeabadoobleWeb.GameComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  import BeabadoobleWeb.CoreComponents

  attr :name, :string, required: true
  attr :status, :atom, required: true, values: ~w(current correct incorrect empty skipped)a
  attr :length, :string, required: true
  attr :placeholder, :string, default: ""

  def guess_input(assigns) do
    ~H"""
    <form class="py-3" phx-submit="submit">
      <div class="flex justify-center items-center">
        <p class="text-center mr-1 font-[RobotoMono] text-lg select-none"><%= @length %>s</p>
        <div class="mx-2 w-full relative overflow-visible">
          <input aria-label="Guess Input" class={"
            guess-input
            w-full font-[RobotoMono] border-2 border-gray-300 rounded-md px-4 py-2 focus:outline-none
            focus:ring-2 focus:ring-[#71c0d6] focus:border-transparent transition duration-200 ease-in-out
            disabled:cursor-not-allowed
            #{case @status do
                :skipped -> "bg-gray-100 text-gray-400 border-gray-200"
                :empty -> "bg-gray-100 text-gray-400 border-gray-200"
                :correct -> "bg-green-50 text-green-700 border-green-500"
                :incorrect -> "bg-red-50 text-red-700 border-red-500"
                _ -> ""
              end}
            "}
            type="text" name={@name} placeholder={@placeholder} autocomplete="off" disabled={@status != :current}
            phx-focus={JS.dispatch("input_focus")} phx-blur={JS.dispatch("input_blur")}/>
          <%= case @status do %>
            <% :correct -> %>
              <.icon name="hero-check" class="absolute right-0 top-1/2 -translate-y-1/2 pr-8 text-green-500" />
            <% :incorrect -> %>
              <.icon name="hero-x-mark" class="absolute right-0 top-1/2 -translate-y-1/2 pr-8 text-red-500" />
            <% _ -> %>
          <% end %>
        </div>
        <button aria-label="Submit Guess" class={"
        ml-2 font-[RobotoMono] bg-gray-200 text-gray-800 hover:bg-gray-300 font-bold py-2
        px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)]
        hover:animate-jiggle disabled:animate-none disabled:cursor-not-allowed
        #{if @status != :current, do: "bg-gray-300 text-gray-500"}
        "}
        disabled={@status != :current} type="submit">Submit</button>
      </div>
    </form>
    """
  end

  attr :game_state, Beabadooble.GameState, required: true

  def audio_player(assigns) do
    ~H"""
    <div id="audio-player" class="bg-white p-4 mb-6 rounded-2xl shadow-[0.25rem_0.25rem_0_0px]" phx-hook="AudioPlayer">
      <div class="flex justify-between items-center space-x-4">
        <button aria-label="Play Audio" id="play-btn" 
          class="bg-[#71c0d6] hover:bg-[#3497b2] text-white font-bold py-2 px-4 rounded-full
          shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition duration-200 ease-in-out
          transform hover:scale-105 hover:rotate-12 active:scale-95 disabled:rotate-0
          disabled:bg-gray-300 disabled:text-gray-500"
        >
          <svg id="play-spinner" class="animate-spin h-6 w-6 m-1 text-gray-700 hidden" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <div id="play-icon">
            <.icon name="hero-play" class="w-8 h-8 aspect-square"/>
          </div>
        </button>
        <div class="w-full bg-gray-200 rounded-full h-5 overflow-hidden">
          <div id="progress" class="bg-[#71c0d6] h-5 rounded-full w-0"></div>
        </div>
        <form phx-submit="skip">
          <button id="skip-btn" aria-label="Skip Audio" 
                  class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold
                  py-2 px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition
                  duration-200 ease-in-out transform hover:scale-105 hover:-rotate-12 active:scale-95
                  disabled:bg-gray-300 disabled:text-gray-500 disabled:rotate-0"
          >
            <.icon name="hero-forward" class="w-8 h-8 aspect-square" />
          </button>
        </form>
      </div>
    </div>
    """
  end

  attr :game_state, Beabadooble.GameState, required: true
  attr :current_song, :map, required: true

  def game_end(assigns) do
    ~H"""
    <div class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6 text-center"> 
      <p :if={@game_state.result == :won} class="text-xl md:text-2xl font-bold">🎉 Congrats, you won!</p>
      <p :if={@game_state.result == :lost} class="text-xl md:text-2xl font-bold">😔 Better luck next time!</p>

      <p class="text-gray-600 mt-2">Song: <span class="font-semibold text-gray-800"><%= @current_song.name %></span></p> 

      <hr class="border-slate-300 my-2">
      
      <div class="my-4">
        <p class="text-xl font-bold mb-1">BEABADOOBLE #<%= @current_song.id %></p>
        <p class="mb-3 text-2xl"><%= select_emojis(@game_state.guesses) %></p>
        <button aria-label="Copy Result" id="copy" phx-hook="Copy" class="bg-gray-200 hover:bg-gray-300 hover:shadow-gray-300 text-gray-800 py-2 px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition duration-200 ease-in-out transform hover:scale-105 active:scale-95">
          <div class="flex items-center">
            <span class="pr-2 text-sm font-bold">COPY</span>
            <.icon name="hero-document-duplicate"/>
          </div>
        </button>
      </div>

      <hr class="border-slate-300 my-2">
      <p class="text-md font-medium font-[RobotoMono] text-gray-600">Next song in</p>
      <p id="countdown" phx-hook="Countdown" class="font-[RobotoMono] text-2xl font-bold"></p>

      <hr class="border-slate-300 my-2">

      <div>
        <p class="text-lg font-semibold">Global Statistics</p>
        <div class="grid grid-cols-3 text-gray-500">
          <div class="flex flex-col">
            <p class="text-2xl font-bold text-green-500 font-[RobotoMono] font-black"><%= @current_song.wins %></p>
            <p class="text-sm">Wins</p>
          </div>

          <div class="flex flex-col">
            <p class="text-2xl font-bold text-red-500 font-[RobotoMono]"><%= @current_song.losses %></p>
            <p class="text-sm">Losses</p>
          </div>

          <div class="flex flex-col">
            <p class="text-2xl font-bold text-blue-500 font-[RobotoMono]"><%= @current_song.wins + @current_song.losses %></p>
            <p class="text-sm">Total Plays</p>
          </div>
        </div>
      </div> 
    </div>
    """
  end

  attr :id, :string, required: true

  def info_modal(assigns) do
    ~H"""
    <.modal id={@id}> 
      <p class="text-center font-[Anybody-Black] text-2xl pb-4">INFO/HOW TO PLAY</p>
      <ul class="list-disc list-inside">
        <li class="mb-2">A new song is featured every day at midnight (UTC)</li>
        <li class="mb-2">To win, you must guess the song title within 3 guesses</li>
        <li class="mb-2">It's recommended to use the autocomplete feature, however guesses are case-insensitive and special characters are ignored for validation</li>
        <li class="mb-2">Progress is saved, so you can make a guess and come back to the site later to complete the puzzle</li>
      </ul>

      <p class="text-center font-[Anybody-Black] text-xl pt-2">Result Emoji Meanings</p>
      <div class="flex justify-center pb-6">
        <ul class="list-disc list-inside">
          <li class="mb-2">💚: Correct Guess</li>
          <li class="mb-2">❤️: Incorrect Guess</li>
          <li class="mb-2">🩶: Skipped Guess</li>
          <li class="mb-2">🖤: No Guess</li>
        </ul>
      </div>

      <p class="text-center">
        <a class="text-gray-500 hover:text-gray-900 hover:underline" href="https://github.com/Leastrio/beabadooble" target="_blank">
          Source Code
        </a>
      </p>
    </.modal>
    """
  end

  attr :id, :string, required: true
  attr :stats, Beabadooble.Stats, required: true

  def stats_modal(assigns) do
    ~H"""
    <.modal id={@id}> 
      <p class="text-center font-[Anybody-Black] text-2xl pb-4">PERSONAL STATS</p>
      <div class="grid grid-cols-2 gap-6 p-4">
        <div class="text-center">
          <p class="text-4xl font-bold mb-2"><%= @stats.won + @stats.lost %></p>
          <p class="text-sm text-gray-600">Games Played</p>
        </div>
        
        <div class="text-center">
          <p class="text-4xl font-bold mb-2"><%= floor(@stats.won / max(@stats.won + @stats.lost, 1) * 100) %>%</p>
          <p class="text-sm text-gray-600">Win Percentage</p>
        </div>
        
        <div class="text-center">
          <p class="text-4xl font-bold mb-2"><%= @stats.won %></p>
          <p class="text-sm text-gray-600">Games Won</p>
        </div>
        
        <div class="text-center">
          <p class="text-4xl font-bold mb-2"><%= @stats.lost %></p>
          <p class="text-sm text-gray-600">Games Lost</p>
        </div>
      </div>
    </.modal>
    """
  end

  attr :id, :string, required: true
  attr :settings, Beabadooble.Settings, required: true

  def settings_modal(assigns) do
    ~H"""
    <.modal id={@id}> 
      <div id="settings" phx-hook="Settings">
        <p class="text-center font-[Anybody-Black] text-2xl pb-4">Settings</p>
        <div class="space-y-2">
          <label for="volume-slider" class="text-lg font-semibold text-gray-700">Volume:</label>
          <div class="flex items-center space-x-4">
            <.icon name="hero-speaker-wave" class="aspect-square"/>
            <input id="volume-slider" type="range" min="1" max="100" value={@settings.volume} class="w-full accent-black rounded-lg cursor-pointer">
            <span id="volume-span" class="font-semibold text-gray-600"><%= @settings.volume %>%</span>
          </div>
        </div>
      </div>
    </.modal>
    """
  end

  attr :icon, :string, required: true
  attr :type, :atom, required: true
  attr :modal_id, :string
  attr :href, :string

  def utility_button(assigns) do
    ~H"""
      <%= case @type do %>
        <% :modal -> %>
          <button phx-click={show_modal(@modal_id)} class="bg-white p-3 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] hover:animate-jiggle">
            <.icon name={@icon} class="size-8"/>
          </button>
        <% :page -> %>
          <button phx-click={JS.navigate(@href)} class="bg-white p-3 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] hover:animate-jiggle">
            <.icon name={@icon} class="size-8"/>
          </button>
      <% end %>
    """
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
end
