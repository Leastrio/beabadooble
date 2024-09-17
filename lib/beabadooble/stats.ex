defmodule Beabadooble.Stats do
  defstruct [:games, :won, :lost]

  def new() do
    %__MODULE__{
      games: 0,
      won: 0,
      lost: 0
    }
  end

  def restore(stats) do
    %__MODULE__{
      games: stats["games"],
      lost: stats["lost"],
      won: stats["won"]
    }
  end
end
