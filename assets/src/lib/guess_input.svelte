<script>
  import Autocomplete from './autocomplete.svelte';
  import { untrack } from 'svelte';

  let { clip_length, guess_index, game_state = $bindable(), channel, end_game, empty_input } = $props();

  let focused = $state(false);
  let should_update = $state(false);
  let is_submitting = $state(false);
  let guesses = $derived(game_state.guesses);
  let input = $state(untrack(() => guesses[guess_index]?.input) || "");
  let status = $derived(guesses[guess_index]?.status || (guesses.length == guess_index ? "current" : "empty"));
  let inputHighlight = $derived({
    "skipped": "bg-gray-100 text-gray-400 border-gray-200",
    "empty": "bg-gray-100 text-gray-400 border-gray-200",
    "correct": "bg-green-50 text-green-700 border-green-500",
    "incorrect": "bg-red-50 text-red-700 border-red-500"
  }[status] || '');
  let placeholder = $derived(status === "skipped" ? "Skipped" : "");


  function submit(e) {
    e.preventDefault();
    if (input === "") {
      empty_input();
      return;
    }

    const timeout = setTimeout(() => {
      is_submitting = true;
    }, 150);

    channel.push("submit_guess", {input})
      .receive("ok", (result) => {
        game_state.guesses[guess_index] = {
          input: input,
          status: result
        };

        if (result === "correct" || guesses.length === 3) {
          end_game()
        }

        clearTimeout(timeout);
        is_submitting = false;
      })
  }

  const focus = () => {
    focused = true;
  }

  const unfocus = () => {
    setTimeout(() => {
      focused = false;
    }, 150);
  }
  
  const handle_input = () => {
    should_update = true;
  }

</script>

<form class="py-3" onsubmit={submit}>
  <div class="flex justify-center items-center">
    <p class="text-center mr-1 font-[RobotoMono] text-lg select-none">{clip_length.toFixed(1)}s</p>
    <div class="mx-2 w-full relative overflow-visible">
      <input
        aria-label="Guess Input" type="text" autocomplete="off" class="w-full font-[RobotoMono] border-2 border-gray-300
        rounded-md px-4 py-2 focus:outline-none focus:ring-2 focus:ring-[#71c0d6] focus:border-transparent
        transition duration-200 ease-in-out disabled:cursor-not-allowed {inputHighlight}"
        disabled={status !== "current"} bind:value={input} placeholder={placeholder} 
        onfocus={focus} onblur={unfocus} oninput={handle_input}
      />
      {#if status === "correct"}
        <span class="absolute right-0 top-1/2 -translate-y-1/2 pr-3 text-green-500">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
          </svg>
        </span>
      {:else if status === "incorrect"}
        <span class="absolute right-0 top-1/2 -translate-y-1/2 pr-3 text-red-500">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
          </svg>
        </span>
      {/if}

      {#if focused && input !== ""}
        <Autocomplete bind:input bind:should_update />
      {/if}
    </div>
    <button aria-label="Submit Guess" class="ml-2 font-[RobotoMono] bg-gray-200 test-gray-800 hover:bg-gray-300 font-bold py-2
      px-4 rounded-full shadow-[0.15rem_0.15rem_0_0px_rgba(0,0,0,0.1)] hover:animate-jiggle disabled:animate-none disabled:cursor-not-allowed
      {status !== "current" ? "bg-gray-300 text-gray-500" : ""}"
      disabled={status !== "current" || is_submitting}
      type="submit"
    >
      <span class="flex items-center justify-center min-w-[4rem]">
        {#if is_submitting}
          <svg class="animate-spin h-5 w-5 text-gray-800" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
        {:else}
          Submit
        {/if}
      </span>
    </button>
  </div>
</form>

