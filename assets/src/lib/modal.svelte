<script>
  import { fade, scale } from 'svelte/transition';
  import { quadOut, backOut } from 'svelte/easing';
  import { modal_states } from './shared.svelte.js';

  let { name, children } = $props();

  let transitioning = $state(false);

  $effect(() => {
    document.body.classList.toggle("overflow-hidden", modal_states[name]);
  });

  function click_away(node) {
    const handle_click = (e) => {
      if (!node.contains(e.target)) {
        modal_states[name] = false;
      }
    }

    document.addEventListener('click', handle_click, true);

    return {
      destroy() {
        document.removeEventListener('click', handle_click, true);
      }
    }
  }
</script>

{#if modal_states[name] == true}
<div class="relative z-50">
  <div 
    class="bg-zinc-50/90 fixed inset-0"
    transition:fade={{duration: 300, easing: quadOut}}
    aria-hidden="true">
  </div>
  <div
    class="fixed inset-0 overflow-y-auto"
    role="dialog"
    aria-modal="true"
    transition:scale={{duration: 500, easing: backOut}}
    onintrostart={() => transitioning = true }
    onoutrostart={() => transitioning = true }
    onintroend={() => transitioning = false }
    onoutroend={() => transitioning = false }
    class:no-scrollbar={transitioning}
  >
    <div class="flex min-h-full items-center justify-center">
      <div class="w-full max-w-xs md:max-w-lg">
        <div
          class="relative rounded-2xl bg-white p-8 md:p-14 max-md:my-6 shadow-[0.25rem_0.25rem_0_0px] ring-1 ring-slate-200"
          use:click_away
        >
          <div class="absolute top-6 right-5">
            <button
              type="button"
              class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
              aria-label="close"
              onclick={() => modal_states[name] = false}
            >
              <span class="h-5 w-5 hero-x-mark-solid"></span>
            </button>
          </div>
          <div>
            {@render children?.()}
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
{/if}

<svelte:window 
  onkeydown={(e) => {
    if (modal_states[name] === true && e.key === "Escape") modal_states[name] = false
  }}
/>

<style>
  .no-scrollbar::-webkit-scrollbar {
      display: none;
  }
  .no-scrollbar {
      -ms-overflow-style: none;
      scrollbar-width: none;
  }
</style>
