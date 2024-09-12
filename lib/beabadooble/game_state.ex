defmodule Beabadooble.GameState do
  defstruct [:guesses, :result, :song_idx, :date]

  defmodule Guess do
    defstruct [:name, :length, :status, :input]
  end

  def new() do
    %__MODULE__{
      guesses: [
        %Guess{name: "guess_one", length: "0.5", status: :current},
        %Guess{name: "guess_two", length: "2.0", status: :empty},
        %Guess{name: "guess_three", length: "5.0", status: :empty}
      ],
      result: :playing,
      song_idx: 0,
      date: Date.utc_today()
    }
  end

  def restore(game_state) do
    data = :json.decode(game_state)

    guesses = Enum.map(data["guesses"], fn g -> 
      %Guess{
        name: g["name"],
        length: g["length"],
        status: String.to_existing_atom(g["status"]),
        input: if(g["input"] == "nil", do: nil, else: g["input"])
      }
    end)

    date = Date.new!(data["date"]["year"], data["date"]["month"], data["date"]["day"])

    if Date.compare(Date.utc_today(), date) == :eq do
      %__MODULE__{
        guesses: guesses,
        result: String.to_existing_atom(data["result"]),
        song_idx: data["song_idx"],
        date: date,
      }
    else
      new()
    end
  end
end
