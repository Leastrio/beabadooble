<script>
  import { completions } from './shared.svelte.js';

  let { input, should_update } = $props();

  let suggestions = $state([]);
  let debounced_autocomplete = debounce(filter_suggestions, 200);

  $effect(() => {
    if (should_update) debounced_autocomplete(input);
  });

  function filter_suggestions(curr) {
    suggestions = $completions.filter(option => option.toLowerCase().includes(curr.toLowerCase()))
  }

  function debounce(func, timeout) {
    let timer;
    return (...args) => {
      clearTimeout(timer);
      timer = setTimeout(() => { func.apply(null, args); }, timeout);
    }
  }

  function handle_click(completion) {
    should_update = false;
    input = completion;
    suggestions = [];
  }

</script>

{#if suggestions.length !== 0}
  <ul class="absolute z-10 w-60 md:w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-auto">
    {#each suggestions as completion}
      <li>
        <button class="px-4 py-2 hover:bg-gray-100 cursor-pointer font-[RobotoMono] text-gray-800 w-full text-left" onclick={() => handle_click(completion)}>
          {completion}
        </button>
      </li>
    {/each}
  </ul>
{/if}
