defmodule Beabadooble.Schema.Songs do
  use Ecto.Schema

  schema "songs" do
    field :name, :string
    field :filename, :string
  end
end
