defmodule BeabadoobleWeb.Router do
  use BeabadoobleWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BeabadoobleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :admin do
    plug :admin_basic_auth
  end

  scope "/", BeabadoobleWeb do
    pipe_through :browser

    live_session :default do
      live "/", IndexLive
      live "/archive", ArchiveLive, :index
      live "/archive/:date", ArchiveLive, :game
    end
  end

  scope "/" do
    pipe_through [:browser, :admin]

    live_dashboard "/dashboard", metrics: BeabadoobleWeb.Telemetry
  end

  defp admin_basic_auth(conn, _opts) do
    username = Application.get_env(:beabadooble, :admin_username)
    password = Application.get_env(:beabadooble, :admin_password)

    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end
end
