defmodule Beabadooble.Stats do
  defstruct [:games, :won, :lost]

  def new() do
    %__MODULE__{
      games: 0,
      won: 0,
      lost: 0
    }
  end

  def restore(nil), do: new()

  def restore(data) do
    stats = :json.decode(data)

    %__MODULE__{
      games: stats["games"],
      lost: stats["lost"],
      won: stats["won"]
    }
  end
end
