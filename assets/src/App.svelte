<script>
  import Interface from './lib/interface.svelte';
  import ActionButton from './lib/action_button.svelte';
  import Archive from './lib/archive.svelte';
  import Game from './lib/game.svelte';
  import {Socket} from "phoenix";
  import { completions, pad } from './lib/shared.svelte.js';
  import { open_db, get_last_played, upsert_state } from './lib/db.svelte.js';
  import { location, route } from './lib/router.svelte.js';
  import InfoModal from './lib/modals/info.svelte';
  import SettingsModal from './lib/modals/settings.svelte';
  import StatsModal from './lib/modals/stats.svelte';
  import { untrack } from 'svelte';

  let game_count = $state(0);
  
  let socket = new Socket("/socket", {
    params: {
      _csrf_token: document.querySelector("meta[name='csrf-token']").getAttribute("content")
    }
  });

  socket.connect();

  let channel = socket.channel("beabadooble:session", {})

  function join_channel() {
    return new Promise((resolve) => {
      channel.join()
        .receive("ok", ({song_list, latest_id}) => {
          $completions = song_list;
          game_count = latest_id;
          resolve();
        })
        .receive("error", resp => { console.log("Unable to join") })
    });
  }

  function init() {
    return new Promise(async (resolve) => {
      await Promise.all([open_db(), join_channel()]);
      resolve();
    });
  }

  const today_formatted = (() => {
    const today = new Date();
    return `${today.getUTCFullYear()}-${pad(today.getUTCMonth() + 1)}-${pad(today.getUTCDate())}`;
  })();
</script>

<InfoModal />
<StatsModal />
<SettingsModal />

{#await init() then}
  {#if location.path === "/"}
    <Game {channel} date={today_formatted}/>
  {:else if ["/archive", "/archive/"].includes(location.path)}
    <Archive {channel} {game_count} />
  {:else if /^\/archive\/(\d{4}-\d{2}-\d{2})\/?$/.test(location.path)}
    <Game {channel} date={window.location.pathname.split("/")[2]}/>
  {:else}
    <div class="bg-white p-4 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] mb-6">
      <h2 class="text-xl md:text-2xl font-bold mb-4 text-center">404 Page Not Found</h2>
      <div class="flex justify-center space-x-3">
        <button aria-label="Back" onclick={() => window.history.back()}>
          <span class="w-8 h-8 aspect-square hero-arrow-uturn-left"></span>
        </button>
        <a use:route href="/" aria-label="Home">
          <span class="w-8 h-8 aspect-square hero-home"></span>
        </a>
      </div>
    </div>
  {/if}
{/await}
<svelte:document ondblclick={(event) => event.preventDefault() } />
