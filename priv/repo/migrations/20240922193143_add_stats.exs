defmodule Beabadooble.Repo.Migrations.AddStats do
  use Ecto.Migration

  def change do
    alter table("daily_songs") do
      add :global_wins, :integer, default: 0
      add :global_losses, :integer, default: 0
    end
  end
end
