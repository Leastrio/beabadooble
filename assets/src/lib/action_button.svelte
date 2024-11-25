<script>
  import { modal_states } from './shared.svelte.js';

  let { type, icon_name, href = null, modal_name = null, ...props } = $props();

</script>

{#if type === "modal"}
<!-- svelte-ignore a11y_consider_explicit_label -->
<button class="bg-white p-3 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] hover:animate-jiggle" onclick={() => modal_states[modal_name] = true} {...props}>
  <span class="w-8 h-8 aspect-square {icon_name}"></span>
</button>
{:else if type === "navigate"}
<!-- svelte-ignore a11y_consider_explicit_label -->
<a {href} data-phx-link="redirect" data-phx-link-state="push" class="bg-white p-3 rounded-2xl shadow-[0.25rem_0.25rem_0_0px] hover:animate-jiggle" {...props}>
  <span class="w-8 h-8 aspect-square {icon_name}"></span>
</a>
{/if}
