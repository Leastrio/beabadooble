defmodule Beabadooble.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:daily_songs) do
      add :date, :date
      add :song_id, references("songs"), null: false
      add :start_time, :integer, null: false
    end

    create index(:daily_songs, [:date])

    create table(:songs) do
      add :name, :string, null: false
      add :filename, :string, null: false
      add :seconds, :integer, null: false
    end
  end
end
