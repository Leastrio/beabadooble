defmodule Beabadooble.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:daily_song, primary_key: false) do
      add :date, :date, primary_key: true
      add :
    end
  end
end
