defmodule Beabadooble.Stats do
  defstruct [:won, :lost]

  def new() do
    %__MODULE__{
      won: 0,
      lost: 0
    }
  end

  def restore(nil), do: new()

  def restore(data) do
    stats = :json.decode(data)

    %__MODULE__{
      lost: stats["lost"],
      won: stats["won"]
    }
  end
end
