defmodule BeabadoobleWeb.Router do
  use BeabadoobleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BeabadoobleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", BeabadoobleWeb do
    pipe_through :browser

    get "/*page", PageController, :home
  end
end
