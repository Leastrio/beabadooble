<script>
  import { archived_games, pad } from './shared.svelte.js';
  import { get_past_game, upsert_state } from './db.svelte.js';
  import { route } from './router.svelte.js';
  import ActionButton from './action_button.svelte';
  import Interface from './interface.svelte';
  import { untrack } from 'svelte'; 

  let { channel, date } = $props();

  let clip_urls = $state([]);
  let game_result = $state("playing");
  let day_info = $state({song_name: null, wins: 0, losses: 0});
  let game_state = $state({day_id: undefined, guesses: []});

  $effect(() => {
    if (game_state.guesses.length !== 0) {
      upsert_state({
        day_id: untrack(() => game_state.day_id),
        date: date,
        guesses: $state.snapshot(game_state.guesses)
      });
    }
  });

  if (window.location.pathname === "/") {
    channel.on("refresh_song", (today) => {
      clip_urls = today.clip_urls;
      game_result = "playing";
      game_state = {day_id: today.id, guesses: []};
      day_info = {song_name: null, wins: 0, losses: 0};
    });

    channel.on("stats_update", ({status}) => {
      if (status == "win") {
        day_info.wins += 1;
      } else {
        day_info.losses += 1;
      }
    });
  }

  function get_song_data(payload) {
    return new Promise((resolve, reject) => {
      channel.push("set_game", payload)
        .receive("ok", (resp) => {
          if (resp === null) {
            reject();
          } else {
            resolve(resp);
          }
        });
    });
  }

  export async function init() {
    const past_state = await get_past_game(date);
    let payload = {date: date, completed: false}

    if (past_state !== undefined) {
      const guesses = past_state.guesses;
      game_state.guesses = guesses;

      if (guesses.length === 3 || guesses[guesses.length - 1].status === "correct") {
        payload.completed = true;
        game_result = guesses[guesses.length - 1].status == "correct" ? "win" : "loss";
      }
    }

    const song_data = await get_song_data(payload)
    game_state.day_id = song_data.id;
    if (payload.completed) {
      day_info = {song_name: song_data.name, wins: song_data.wins, losses: song_data.losses}
    } else {
      clip_urls = song_data.clip_urls;
    }
  }
</script>

{#await init() then}
  {#if window.location.pathname !== "/" && game_result === "playing"}
    <div class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6">
      <div class="relative">
        <a use:route href="/archive" class="hover:animate-jiggle absolute left-0" aria-label="Back">
          <span class="w-7 h-7 aspect-square hero-arrow-uturn-left"></span>
        </a>
        <h2 class="text-xl md:text-2xl font-bold text-center mx-auto">Game #{game_state.day_id}</h2>
      </div>
    </div>
  {/if}
  <Interface {clip_urls} bind:game_result {date} bind:day_info {channel} bind:game_state />
  <div class="flex justify-end space-x-3 mb-6">
    <ActionButton type="modal" modal_name="info" icon_name="hero-information-circle" aria-label="Information"/>
    {#if window.location.pathname === "/" || game_result !== "playing"}
      <ActionButton type="navigate" href="/archive" icon_name="hero-calendar" aria-label="Archived Games"/>
    {:else}
      <ActionButton type="navigate" href="/" icon_name="hero-home" aria-label="Home"/>
    {/if}
    <ActionButton type="modal" modal_name="stats" icon_name="hero-chart-bar" aria-label="Personal Stats"/>
    <ActionButton type="modal" modal_name="settings" icon_name="hero-cog-8-tooth" aria-label="Settings"/>
  </div>
{:catch}
<div class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6">
  <h2 class="text-xl md:text-2xl font-bold mb-4 text-center">Game Not Found!</h2>
  <div class="flex justify-center space-x-3">
    <button aria-label="Back" onclick={() => window.history.back()}>
      <span class="w-8 h-8 aspect-square hero-arrow-uturn-left"></span>
    </button>
    <a use:route href="/" aria-label="Home">
      <span class="w-8 h-8 aspect-square hero-home"></span>
    </a>
  </div>
</div>
{/await}


