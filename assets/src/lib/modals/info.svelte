<script>
  import Modal from '../modal.svelte';
  import { modal_states } from '../shared.svelte.js';

  modal_states["info"] = false;
</script>


<Modal name="info">
  <p class="text-center font-[Anybody-Black] text-2xl pb-4">INFO/HOW TO PLAY</p>
  <ul class="list-disc list-inside">
    <li class="mb-2">A new song is featured every day at midnight (UTC)</li>
    <li class="mb-2">To win, you must guess the song title within 3 guesses</li>
    <li class="mb-2">It's recommended to use the autocomplete feature, however guesses are case-insensitive and special characters are ignored for validation</li>
    <li class="mb-2">Progress is saved, so you can make a guess and come back to the site later to complete the puzzle</li>
  </ul>

  <p class="text-center font-[Anybody-Black] text-xl pt-2">Result Emoji Meanings</p>
  <div class="flex justify-center pb-6">
    <ul class="list-disc list-inside">
      <li class="mb-2">💚: Correct Guess</li>
      <li class="mb-2">❤️: Incorrect Guess</li>
      <li class="mb-2">🩶: Skipped Guess</li>
      <li class="mb-2">🖤: No Guess</li>
    </ul>
  </div>

  <p class="text-center">
    <a class="text-gray-500 hover:text-gray-900 hover:underline" href="https://github.com/Leastrio/beabadooble" target="_blank">
      Source Code
    </a>
  </p>
</Modal>
