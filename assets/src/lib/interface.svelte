<script>
  import GuessInput from './guess_input.svelte';
  import AudioPlayer from './audio_player.svelte';
  import ActionButton from './action_button.svelte';
  import EndGame from './end_game.svelte';
  import InfoModal from './modals/info.svelte';
  import SettingsModal from './modals/settings.svelte';
  import StatsModal from './modals/stats.svelte';
  import { game_state, audio_buffers, completions, personal_stats } from './shared.svelte.js';
  import { scale } from 'svelte/transition';
  import { backOut } from 'svelte/easing';

  let { clip_urls, channel, game_result = $bindable(), day_info = $bindable() } = $props();

  let error_message = $state(null);
  let guesses = $derived(game_state.guesses);

  function end_game() {
    const audio = $audio_buffers[guesses.length - 1];
    if (audio.playing()) {
      audio.stop();
    }
    game_result = guesses[guesses.length - 1].status == "correct" ? "win" : "loss";

    personal_stats[game_result === "win" ? "won" : "lost"] += 1;

    channel.push("end_game", {game_result})
      .receive("ok", (resp) => {
        day_info.song_name = resp.name;
        day_info.wins = resp.wins;
        day_info.losses = resp.losses;
      });
  }

  function set_message(msg) {
    error_message = msg;
    setTimeout(() => {
      error_message = null;
    }, 2500);
  }

</script>

<InfoModal />
<StatsModal />
<SettingsModal />

{#if error_message}
<div
  id="message-container"
  class="bg-rose-400 p-10 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] shadow-rose-700 mb-6"
  transition:scale={{duration: 500, easing: backOut}}
>
  <p class="text-center text-white text-2xl font-[Anybody-Black] select-none">
    {error_message}
  </p>
</div>
{/if}

{#if game_result === "playing"}
  <div class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6">
    {#each [0.5, 1.0, 2.5] as clip_length, guess_index}
      <GuessInput {clip_length} {guess_index} {channel} {end_game} empty_input={() => set_message("Please enter a guess!")}/>
      {#if guess_index < 2}
        <hr class="border-slate-300" />
      {/if}
    {/each}
  </div>
  <AudioPlayer {clip_urls} {end_game}/>
{:else}
  <EndGame {day_info} {game_result}/>
{/if}

<div class="flex justify-end space-x-3 mb-6">
  <ActionButton type="modal" modal_name="info" icon_name="hero-information-circle" aria-label="Information"/> <!-- info modal -->
  <!--<ActionButton type="navigate" href="/archive" icon_name="hero-calendar" aria-label="Archived Games"/> <!-- archive redirect -->
  <ActionButton type="modal" modal_name="stats" icon_name="hero-chart-bar" aria-label="Personal Stats"/> <!-- stats modal -->
  <ActionButton type="modal" modal_name="settings" icon_name="hero-cog-8-tooth" aria-label="Settings"/> <!-- settings modal -->
</div>
