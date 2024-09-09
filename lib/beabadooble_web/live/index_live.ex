defmodule BeabadoobleWeb.IndexLive do
  use BeabadoobleWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
      <%= if @message do %>
        <div
          id="message-container"
          class="bg-rose-400 p-10 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] shadow-rose-700 mb-6"
          phx-mounted={JS.transition({"animate-pop-in", "opacity-0", "opacity-100"}, time: 500)}
          phx-remove={JS.hide(transition: {"animate-pop-out", "opacity-100", "opacity-0"}, time: 500)}
        >
          <p class="text-center text-white text-2xl font-[Anybody-Black] select-none"><%= @message %></p>
        </div>
      <% end %>

      <div id="game" class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6" phx-hook="Session">
        <datalist id="suggestions">
          <%= for song <- @songs do %>
            <option value={song}><%= song %></option>
          <% end %>
        </datalist>
        <.guess_input name="guess_one" length="0.5" status={:disabled} placeholder="Skipped"/>
        <hr class="border-slate-300">
        <.guess_input name="guess_two" length="2.0" status={:current} placeholder="Enter a guess!"/>
        <hr class="border-slate-300">
        <.guess_input name="guess_three" length="5.0" status={:disabled}/>
      </div>

    <div id="audio-player" class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px]" phx-hook="AudioPlayer">
      <div class="flex justify-between items-center space-x-4">
        <button id="play" class="bg-[#71c0d6] hover:bg-[#3497b2] text-white font-bold py-2 px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition duration-200 ease-in-out transform hover:scale-105 hover:rotate-12 active:scale-95">
          <.icon name="hero-play" class="w-8 h-8 aspect-square"/>
        </button>
        <div class="w-full bg-gray-200 rounded-full h-5 overflow-hidden">
          <div id="progress" class="bg-[#71c0d6] h-5 rounded-full w-0"></div>
        </div>
        <form phx-submit="skip">
          <button class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-2 px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition duration-200 ease-in-out transform hover:scale-105 hover:-rotate-12 active:scale-95">
            <.icon name="hero-forward" class="w-8 h-8 aspect-square" />
          </button>
        </form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket = socket
    |> assign(songs: Beabadooble.Constants.songs(), message: nil, timer: nil)
    |> push_event("session:set_audio", %{url: "https://upload.wikimedia.org/wikipedia/en/a/a9/Webern_-_Sehr_langsam.ogg"})

    {:ok, socket}
  end

  @impl true
  def handle_event("submit", %{"guess_one" => guess}, socket) when guess != "" do
    {:noreply, socket}
  end

  @impl true
  def handle_event("submit", params, socket) do
    socket = case params do
      %{"guess_one" => ""} -> socket |> put_message("Please enter a guess!")
      %{"guess_two" => ""} -> socket |> put_message("Please enter a guess!")
      %{"guess_three" => ""} -> socket |> put_message("Please enter a guess!")
      _ -> socket
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("skip", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:clear_message, socket) do
    {:noreply, socket |> assign(message: nil, timer: nil)}
  end

  defp put_message(socket, msg) do
    if not is_nil(socket.assigns.timer) do
      Process.cancel_timer(socket.assigns.timer)
    end
    timer_ref = Process.send_after(self(), :clear_message, 2500)
    assign(socket, message: msg, timer: timer_ref)
  end
end
