<script>
  import { pad, personal_stats } from './shared.svelte.js';
  import { Confetti } from 'svelte-confetti';

  let { day_info, game_result, game_state, date } = $props();

  let countdown = $state();
  let now;
  let copied = $state(false);

  function select_emojis() {
    return [...Array(3)].map((_, idx) => ({
        "correct": "💚",
        "incorrect": "❤️",
        "skipped": "🩶"
      }[game_state.guesses[idx]?.status] ?? "🖤")).join("")
  }

  function start_countdown(node) {
    const interval = setInterval(() => {
      now = new Date();
      let hours = 23 - now.getUTCHours();
      let minutes = 59 - now.getUTCMinutes();
      let seconds = 59 - now.getUTCSeconds();
      countdown = `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
    });

    return {
      destroy() {
        clearInterval(interval);
      }
    }
  }

  async function copy(e) {
    e.preventDefault();
    let [_year, month, day] = date.split("-");
    let streak_text = (window.location.pathname === "/" && personal_stats.streak > 1 && personal_stats.streak % 5 === 0)
    ? `🔥 Streak: ${personal_stats.streak}\n` 
    : "";

    let text = `BEABADOOBLE #${game_state.day_id} ${month}/${day}\n\n${select_emojis()}\n\n${streak_text}<https://beabadooble.com>`;
    await navigator.clipboard.writeText(text);

    copied = true;
    setTimeout(() => {
      copied = false;
    }, 900);
  }
</script>

{#if game_result === "win"}
<div class="fixed top-[-50px] left-0 h-screen w-screen flex justify-center overflow-hidden pointer-events-none z-50">
  <Confetti x={[-5, 5]} y={[0, 0.1]} delay={[500, 2000]} infinite duration=5000 amount=200 fallDistance="100vh" />
</div>
{/if}

<div class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6 text-center">
  {#if game_result === "win"}
  <p class="text-xl md:text-2xl font-bold">
    🎉 Congrats, you won!
  </p>
  {:else if game_result === "loss"}
  <p class="text-xl md:text-2xl font-bold">
    😔 Better luck next time!
  </p>
  {/if}

  <p class="text-gray-600 mt-2">
    Song: <span class="font-semibold text-gray-800">{day_info.song_name}</span>
  </p>

  <hr class="border-slate-300 my-2" />

  <div class="my-4">
    <p class="text-xl font-bold">BEABADOOBLE #{game_state.day_id}</p>
    {#if window.location.pathname === "/" && personal_stats.streak > 1}
      <p class="text-gray-600">Daily Streak: <span class="font-semibold text-gray-800">{personal_stats.streak}</span> 🔥</p>
    {/if}
    <p class="mt-1 mb-3 text-2xl">{select_emojis()}</p>
    <button
      aria-label="Copy Result"
      class="bg-gray-200 hover:bg-gray-300 hover:shadow-gray-300 text-gray-800 py-2 px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition duration-200 ease-in-out transform hover:scale-105 active:scale-95"
      onclick={copy}
      class:bg-green-200={copied}
      class:hover:bg-green-200={copied}
    >
      <div class="flex items-center">
        <span class="pr-2 text-sm font-bold">{copied ? "COPIED!" : "COPY"}</span>
        <span class="aspect-square">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125h-9.75a1.125 1.125 0 0 1-1.125-1.125V7.875c0-.621.504-1.125 1.125-1.125H6.75a9.06 9.06 0 0 1 1.5.124m7.5 10.376h3.375c.621 0 1.125-.504 1.125-1.125V11.25c0-4.46-3.243-8.161-7.5-8.876a9.06 9.06 0 0 0-1.5-.124H9.375c-.621 0-1.125.504-1.125 1.125v3.5m7.5 10.375H9.375a1.125 1.125 0 0 1-1.125-1.125v-9.25m12 6.625v-1.875a3.375 3.375 0 0 0-3.375-3.375h-1.5a1.125 1.125 0 0 1-1.125-1.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H9.75" />
          </svg>
        </span>
      </div>
    </button>
  </div>

  {#if window.location.pathname === "/"}
    <hr class="border-slate-300 my-2" />
    <p class="text-md font-medium font-[RobotoMono] text-gray-600">Next song in</p>
    <p class="font-[RobotoMono] text-2xl font-bold" use:start_countdown>{countdown}</p>
  {/if}

  <hr class="border-slate-300 my-2" />

  <div>
    <p class="text-lg font-semibold">Global Statistics</p>
    <div class="grid grid-cols-3 text-gray-500">
      <div class="flex flex-col">
        <p class="text-2xl font-bold text-green-500 font-[RobotoMono]">
          {day_info.wins}
        </p>
        <p class="text-sm">Wins</p>
      </div>

      <div class="flex flex-col">
        <p class="text-2xl font-bold text-red-500 font-[RobotoMono]">
          {day_info.losses}
        </p>
        <p class="text-sm">Losses</p>
      </div>

      <div class="flex flex-col">
        <p class="text-2xl font-bold text-blue-500 font-[RobotoMono]">
          {day_info.wins + day_info.losses}
        </p>
        <p class="text-sm">Total Plays</p>
      </div>
    </div>
  </div>
</div>
