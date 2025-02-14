import { writable } from 'svelte/store';

export const pad = (num) => num.toString().padStart(2, "0");

export const completions = writable([]);
export const modal_states = $state({});
export const archived_games = $state({value: []});

export const personal_stats = $state({
  ...{won: 0, lost: 0, streak: 0},
  ...JSON.parse(localStorage.getItem("stats"))
});

$effect.root(() => {
  $effect(() => {
    localStorage.setItem("stats", JSON.stringify($state.snapshot(personal_stats)));
  });
});

export const settings = $state(JSON.parse(localStorage.getItem("settings")) ?? {volume: 100});

$effect.root(() => {
  $effect(() => {
    localStorage.setItem("settings", JSON.stringify(settings));
  });
});
