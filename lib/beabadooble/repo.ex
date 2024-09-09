defmodule Beabadooble.Repo do
  use Ecto.Repo,
    otp_app: :beabadooble,
    adapter: Ecto.Adapters.SQLite3
end
