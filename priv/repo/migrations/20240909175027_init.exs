defmodule Beabadooble.Repo.Migrations.Init do
  use Ecto.Migration

  def change do
    create table(:daily_songs) do
      add :date, :date
      add :song, references("songs"), null: false
    end

    create index(:daily_songs, [:date])

    create table(:songs) do
      add :name, :string, null: false
      add :filename, :string, null: false
    end
  end
end
