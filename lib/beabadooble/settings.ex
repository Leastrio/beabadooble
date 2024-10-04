defmodule Beabadooble.Settings do
  defstruct [:volume]

  def new() do
    %__MODULE__{
      volume: "100",
    }
  end

  def restore(nil), do: new()

  def restore(data) do
    settings = :json.decode(data)

    %__MODULE__{
      volume: settings["volume"],
    }
  end
end
