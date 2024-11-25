defmodule BeabadoobleWeb.PageController do
  use BeabadoobleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
