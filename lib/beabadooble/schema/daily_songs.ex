defmodule Beabadooble.Schema.DailySongs do
  use Ecto.Schema

  schema "daily_songs" do
    field :date, :date
    field :song_id, :id
    has_one :song, Beabadooble.Schema.Songs, foreign_key: :id, references: :song_id
    field :start_time, :integer
    field :global_wins, :integer, default: 0
    field :global_losses, :integer, default: 0
  end
end
