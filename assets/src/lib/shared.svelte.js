import { writable } from 'svelte/store';

export const pad = (num) => num.toString().padStart(2, "0");

export const completions = writable([]);
export const modal_states = $state({});
export const archived_games = $state({value: []});

export const personal_stats = $state(JSON.parse(localStorage.getItem("stats")) ?? {won: 0, lost: 0});

$effect.root(() => {
  $effect(() => {
    const { won, lost } = personal_stats;
    localStorage.setItem("stats", JSON.stringify({won, lost}));
  });
});

export const settings = $state(JSON.parse(localStorage.getItem("settings")) ?? {volume: 100});

$effect.root(() => {
  $effect(() => {
    localStorage.setItem("settings", JSON.stringify(settings));
  });
});
