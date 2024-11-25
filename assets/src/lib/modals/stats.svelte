<script>
  import Modal from '../modal.svelte';
  import { modal_states, personal_stats } from '../shared.svelte.js';

  modal_states["stats"] = false;
  
  let wins = $derived(personal_stats.won);
  let losses = $derived(personal_stats.lost);
  let total = $derived(wins + losses);
  let win_perc = $derived(Math.floor(wins / Math.max(total, 1) * 100))
</script>


<Modal name="stats">
  <p class="text-center font-[Anybody-Black] text-2xl pb-4">PERSONAL STATS</p>
  <div class="grid grid-cols-2 gap-6 p-4">
    <div class="text-center">
      <p class="text-4xl font-bold mb-2">{total}</p>
      <p class="text-sm text-gray-600">Games Played</p>
    </div>
    
    <div class="text-center">
      <p class="text-4xl font-bold mb-2">{win_perc}%</p>
      <p class="text-sm text-gray-600">Win Percentage</p>
    </div>
    
    <div class="text-center">
      <p class="text-4xl font-bold mb-2">{wins}</p>
      <p class="text-sm text-gray-600">Games Won</p>
    </div>
    
    <div class="text-center">
      <p class="text-4xl font-bold mb-2">{losses}</p>
      <p class="text-sm text-gray-600">Games Lost</p>
    </div>
  </div>
</Modal>
