defmodule BeabadoobleWeb.GameComponents do
  use Phoenix.Component

  import BeabadoobleWeb.CoreComponents

  attr :name, :string, required: true
  attr :status, :atom, required: true, values: ~w(current correct incorrect empty skipped)a
  attr :length, :string, required: true
  attr :placeholder, :string, default: ""

  def guess_input(assigns) do
    ~H"""
    <form class="py-3" phx-submit="submit">
      <div class="flex justify-center items-center">
        <p class="text-center mr-1 font-[RobotoMono] text-lg select-none"><%= @length %>s</p>
        <div class="mx-2 w-full relative">
          <input aria-label="Guess Input" class={"
            w-full font-[RobotoMono] border-2 border-gray-300 rounded-md px-4 py-2 focus:outline-none
            focus:ring-2 focus:ring-[#71c0d6] focus:border-transparent transition duration-200 ease-in-out disabled:cursor-not-allowed
            #{case @status do
                :skipped -> "bg-gray-100 text-gray-400 border-gray-200"
                :empty -> "bg-gray-100 text-gray-400 border-gray-200"
                :correct -> "bg-green-50 text-green-700 border-green-500"
                :incorrect -> "bg-red-50 text-red-700 border-red-500"
                _ -> ""
              end}
            "}
            type="text" name={@name} list={@status == :current && "suggestions"} placeholder={@placeholder} autocomplete="off" disabled={@status != :current}/>
          <%= case @status do %>
            <% :correct -> %>
              <.icon name="hero-check" class="absolute right-0 top-1/2 -translate-y-1/2 pr-8 text-green-500" />
            <% :incorrect -> %>
              <.icon name="hero-x-mark" class="absolute right-0 top-1/2 -translate-y-1/2 pr-8 text-red-500" />
            <% _ -> %>
          <% end %>
        </div>
        <button aria-label="Submit Guess" class={"
        ml-2 font-[RobotoMono] bg-gray-200 text-gray-800 hover:bg-gray-300 font-bold py-2
        px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] hover:animate-jiggle disabled:animate-none disabled:cursor-not-allowed
        #{if @status != :current, do: "bg-gray-300 text-gray-500"}
        "}
        disabled={@status != :current} type="submit">Submit</button>
      </div>
    </form>
    """
  end
end
