defmodule BeabadoobleWeb.ArchiveLive do
  use BeabadoobleWeb, :live_view
  import BeabadoobleWeb.GameComponents
  alias Beabadooble.{Stats, Settings}

  @impl true
  def render(assigns) do
    ~H"""
      <.info_modal id="info-modal" />
      <.stats_modal id="stats-modal" stats={@stats}/>
      <.settings_modal id="settings-modal" settings={@settings} />

      <%= if @live_action == :index do %>
        <div class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6">
          hi
        </div>
      <% else %>
        hello 
      <% end %>

      <div class="flex justify-end space-x-3 mb-6">
        <.utility_button icon="hero-information-circle" type={:modal} modal_id="info-modal" />
        <.utility_button icon="hero-calendar" type={:page} href={~p"/archive"} />
        <.utility_button icon="hero-chart-bar" type={:modal} modal_id="stats-modal" />
        <.utility_button icon="hero-cog-8-tooth" type={:modal} modal_id="settings-modal" />
      </div>
    """
  end
  
  @impl true
  def mount(_params, _session, socket) do
    {stats, settings} = case get_connect_params(socket) do
      nil -> {Stats.new(), Settings.new()}
      %{"restore" => nil} -> {Stats.new(), Settings.new()}
      %{"restore" => %{"stats" => stats, "settings" => settings}} -> 
        {Stats.restore(stats), Settings.restore(settings)}
    end

    socket = socket
      |> assign(
        stats: stats,
        settings: settings
      )

    {:ok, socket}
  end
end
