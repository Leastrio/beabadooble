defmodule Beabadooble.GameState do
  defstruct [:guesses, :result, :song_idx, :date]

  defmodule Guess do
    defstruct [:name, :length, :status, :input]
  end

  def new() do
    %__MODULE__{
      guesses: [
        %Guess{name: "guess_one", length: "0.5", status: :current},
        %Guess{name: "guess_two", length: "1.0", status: :empty},
        %Guess{name: "guess_three", length: "2.5", status: :empty}
      ],
      result: :playing,
      song_idx: 0,
      date: Date.utc_today()
    }
  end

  def restore(game_state) do
    guesses = Enum.map(game_state["guesses"], fn g -> 
      %Guess{
        name: g["name"],
        length: g["length"],
        status: String.to_existing_atom(g["status"]),
        input: if(g["input"] == "nil", do: nil, else: g["input"])
      }
    end)

    date = Date.new!(game_state["date"]["year"], game_state["date"]["month"], game_state["date"]["day"])

    if Date.compare(Date.utc_today(), date) == :eq do
      %__MODULE__{
        guesses: guesses,
        result: String.to_existing_atom(game_state["result"]),
        song_idx: game_state["song_idx"],
        date: date,
      }
    else
      new()
    end
  end
end
