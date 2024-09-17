defmodule BeabadoobleWeb.GameComponents do
  use Phoenix.Component

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
        <div class="mx-2 w-full relative">
          <input aria-label="Guess Input" class={"
            w-full font-[RobotoMono] border-2 border-gray-300 rounded-md px-4 py-2 focus:outline-none
            focus:ring-2 focus:ring-[#71c0d6] focus:border-transparent transition duration-200 ease-in-out disabled:cursor-not-allowed
            #{case @status do
                :skipped -> "bg-gray-100 text-gray-400 border-gray-200"
                :empty -> "bg-gray-100 text-gray-400 border-gray-200"
                :correct -> "bg-green-50 text-green-700 border-green-500"
                :incorrect -> "bg-red-50 text-red-700 border-red-500"
                _ -> ""
              end}
            "}
            type="text" name={@name} list={@status == :current && "suggestions"} placeholder={@placeholder} autocomplete="off" disabled={@status != :current}/>
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
        px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] hover:animate-jiggle disabled:animate-none disabled:cursor-not-allowed
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

  attr :game_state, Beabadooble.GameState, required: true
  attr :current_song, :map, required: true

  def game_end(assigns) do
    ~H"""
    <div class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6 text-center"> 
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
