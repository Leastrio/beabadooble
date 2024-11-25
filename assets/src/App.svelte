<script>
  import Interface from './lib/interface.svelte';
  import {Socket} from "phoenix";
  import { game_state, audio_buffers, completions } from './lib/shared.svelte.js';
  import { open_db } from './lib/db.js';
  import { onMount } from 'svelte';

  let clip_urls = $state([]);
  let game_result = $state("playing");
  let day_info = $state({song_name: null, wins: 0, losses: 0})

  let socket = new Socket("/socket", {
    params: {
      _csrf_token: document.querySelector("meta[name='csrf-token']").getAttribute("content")
    }
  });

  socket.connect();

  let channel = socket.channel("beabadooble:session", {})
  channel.on("refresh_song", (today) => {
      game_state.guesses = []
      $audio_buffers = [];
      day_info = today;
    });

  channel.on("stats_update", ({status}) => {
      if (status == "win") {
        day_info.wins += 1;
      } else {
        day_info.losses += 1;
      }
    });

  function join_channel() {
    return new Promise((resolve) => {
      channel.join()
        .receive("ok", ({today, song_list}) => {
          $completions = song_list;
          resolve(today);
        })
        .receive("error", resp => { console.log("Unable to join") })
    });
  }

  onMount(async () => {
    const [today, latest_state] = await Promise.all([join_channel(), open_db()]);
    
    game_state.day_id = today.id;
    clip_urls = today.clip_urls;

    if (today.id === latest_state?.day_id) {
      const guesses = latest_state.guesses;
      game_state.guesses = guesses;

      if (guesses.length === 3 || guesses[guesses.length - 1].status === "correct") {
        channel.push("end_game", {})
          .receive("ok", (resp) => {
            day_info.song_name = resp.name;
            day_info.wins = resp.wins;
            day_info.losses = resp.losses;
          });
        game_result = guesses[guesses.length - 1].status == "correct" ? "win" : "loss";
      }
    }
  })


</script>

{#key game_state.day_id}
  <Interface {clip_urls} {game_result} {day_info} {channel} />
{/key}
