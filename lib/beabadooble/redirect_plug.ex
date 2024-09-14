defmodule Beabadooble.RedirectPlug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _options) do
    if String.starts_with?(conn.host, "beabadooble.fly.dev") do
      conn
      |> Phoenix.Controller.redirect(external: "https://beabadooble.com")
      |> halt()
    else
      conn
    end
  end
end
