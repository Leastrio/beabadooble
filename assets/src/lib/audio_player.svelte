<script>
  import { game_state, audio_buffers, settings } from './shared.svelte.js';
  import { onMount } from 'svelte';
  import {Howler, Howl} from 'howler'

  let { clip_urls = [], end_game } = $props();

  let animation;
  let progress_bar;
  let loaded = $derived($audio_buffers.length > 0);
  let guesses = $derived(game_state.guesses);

  $effect(async () => {
    const audio_promises = clip_urls.map((url) => {
      return new Promise((resolve, reject) => {
        const audio = new Howl({
          src: [url],
          preload: true,
          onload: () => {
            resolve(audio);
          }
        });

        if (audio.state() === 'loaded') {
          resolve(audio);
        }
      })
    })

    const buffers = await Promise.all(audio_promises);
    $audio_buffers = buffers.sort((a, b) => a.duration() - b.duration());
  })

  $effect(() => {
    Howler.volume(settings.volume / 100);
  })

  function play() {
    const audio = $audio_buffers[guesses.length];
    if (audio.playing()) {
      audio.stop();

      if (animation) {
        animation.cancel();
      }
    }

    audio.play();
    animation = progress_bar.animate({'width': audio.duration() / 2.5 * 100 + "%"}, audio.duration() * 1000, 'linear');
  }

  function skip() {
    game_state.guesses = [...guesses, {
        input: "",
        status: "skipped"
      }];

    if (guesses.length === 3) {
      end_game();
    }
  }
</script>

<div class="bg-white p-4 mb-6 rounded-2xl shadow-[0.25rem_0.25rem_0_0px]">
  <div class="flex justify-between items-center space-x-4">
    <button
      aria-label="Play Audio"
      disabled={!loaded}
      onclick={play}
      class="bg-[#71c0d6] hover:bg-[#3497b2] text-white font-bold py-2 px-4 rounded-full
      shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition duration-200 ease-in-out
      transform hover:scale-105 hover:rotate-12 active:scale-95 disabled:rotate-0
      disabled:bg-gray-300 disabled:text-gray-500"
    >
      <svg
        class="animate-spin h-6 w-6 m-1 text-gray-700"
        class:hidden={loaded}
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
        </circle>
        <path
          class="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        >
        </path>
      </svg>
      <div class:hidden={!loaded}>
        <span class="w-8 h-8 aspect-square">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
            <path stroke-linecap="round" stroke-linejoin="round" d="M5.25 5.653c0-.856.917-1.398 1.667-.986l11.54 6.347a1.125 1.125 0 0 1 0 1.972l-11.54 6.347a1.125 1.125 0 0 1-1.667-.986V5.653Z" />
          </svg>
        </span>
      </div>
    </button>
    <div class="w-full bg-gray-200 rounded-full h-5 overflow-hidden">
      <div bind:this={progress_bar} class="bg-[#71c0d6] h-5 rounded-full w-0"></div>
    </div>
    <button
      aria-label="Skip Audio"
      disabled={!loaded}
      onclick={skip}
      class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold
            py-2 px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] transition
            duration-200 ease-in-out transform hover:scale-105 hover:-rotate-12 active:scale-95
            disabled:bg-gray-300 disabled:text-gray-500 disabled:rotate-0"
    >
      <span class="w-8 h-8 aspect-square">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
          <path stroke-linecap="round" stroke-linejoin="round" d="M3 8.689c0-.864.933-1.406 1.683-.977l7.108 4.061a1.125 1.125 0 0 1 0 1.954l-7.108 4.061A1.125 1.125 0 0 1 3 16.811V8.69ZM12.75 8.689c0-.864.933-1.406 1.683-.977l7.108 4.061a1.125 1.125 0 0 1 0 1.954l-7.108 4.061a1.125 1.125 0 0 1-1.683-.977V8.69Z" />
        </svg>
      </span>
    </button>
  </div>
</div>
