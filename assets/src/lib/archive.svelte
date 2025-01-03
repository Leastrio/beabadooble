<script>
  import ActionButton from './action_button.svelte';
  import { pad, archived_games, } from './shared.svelte.js';
  import { get_all_history, db_connection } from './db.svelte.js';
  import { route } from './router.svelte.js';
  import { onMount, onDestroy } from 'svelte';

  let { channel, game_count } = $props();

  if (archived_games.value.length === 0) {
    archived_games.value = Array.from({ length: game_count }, (_, i) => {
      const date = new Date()
      date.setUTCDate(date.getUTCDate() - i);
      return {
        id: game_count - i,
        date: date.toISOString().slice(0, 10),
        completed: false,
        won: false
      }
    });
  }

  onMount(async () => {
    const history = await get_all_history();

    history.forEach(({ day_id, guesses }) => {
      const last_guess = guesses[guesses.length - 1];
      archived_games.value[game_count - day_id].completed = guesses.length === 3 || last_guess.status === "correct";
      archived_games.value[game_count - day_id].won = last_guess.status === "correct";
    });
  });

  const today = new Date();
  const today_formatted = `${today.getUTCFullYear()}-${pad(today.getUTCMonth() + 1)}-${pad(today.getUTCDate())}`

</script>

<div class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6">
  <h2 class="text-xl md:text-2xl font-bold mb-4 text-center">Archived Games</h2>
  <div class="grid grid-cols-2 gap-2">
    {#each archived_games.value as game (game.id)}
      <a use:route href={today_formatted === game.date ? "/" : `/archive/${game.date}`}>
        <div
          class="p-3 rounded-lg transition-colors duration-200 ease-in-out cursor-pointer
                 {game.completed ? (game.won ? 'bg-green-100 hover:bg-green-200' : 'bg-red-100 hover:bg-red-200') : 'bg-gray-100 hover:bg-gray-200'}"
        >
          <div class="flex flex-col sm:flex-row sm:justify-between sm:items-center">
            <span class="font-semibold">#{game.id}</span>
            <span class="text-sm text-gray-600 mt-1 sm:mt-0">
              {today_formatted === game.date ? "Today" : game.date}
            </span>
          </div>
          {#if game.completed}
            <div class="mt-1 sm:mt-2 text-sm text-left">
              {#if game.won}
                <span class="text-green-600">Won</span>
              {:else}
                <span class="text-red-600">Lost</span>
              {/if}
            </div>
          {:else}
            <div class="mt-2 text-sm text-gray-600 text-left">Not played</div>
          {/if}
        </div>
      </a>
    {/each}
  </div>
</div>

<div class="flex justify-end space-x-3 mb-6">
  <ActionButton type="modal" modal_name="info" icon_name="hero-information-circle" aria-label="Information"/>
  <ActionButton type="navigate" href="/" icon_name="hero-home" aria-label="Home"/>
  <ActionButton type="modal" modal_name="stats" icon_name="hero-chart-bar" aria-label="Personal Stats"/>
  <ActionButton type="modal" modal_name="settings" icon_name="hero-cog-8-tooth" aria-label="Settings"/>
</div>
