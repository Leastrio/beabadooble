defmodule Beabadooble.Schema.DailySongs do
  use Ecto.Schema

  schema "daily_songs" do
    field :date, :date
    field :song, :id
  end
end
