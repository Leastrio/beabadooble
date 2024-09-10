defmodule Beabadooble.GameState do
  defstruct [:guesses, :result]

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
      result: :won
    }
  end
end
