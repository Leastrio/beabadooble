<script>
  import Modal from '../modal.svelte';
  import { modal_states, settings } from '../shared.svelte.js';

  modal_states["settings"] = false;
</script>


<Modal name="settings">
  <p class="text-center font-[Anybody-Black] text-2xl pb-4">Settings</p>
  <div class="space-y-2">
    <label for="volume-slider" class="text-lg font-semibold text-gray-700">Volume:</label>
    <div class="flex flex-wrap items-center gap-4">
      <span class="hero-speaker-wave aspect-square"></span>
      <div class="flex-1 min-w-[200px] flex items-center gap-4">
        <input type="range" min="1" max="100" bind:value={settings.volume} class="w-full accent-black rounded-lg cursor-pointer">
        <span class="font-semibold text-gray-600 w-14 text-center flex-none">{settings.volume}%</span>
      </div>
    </div>
  </div>
</Modal>
