import { writable } from 'svelte/store';
import { untrack } from 'svelte';
import { upsert_state } from './db.js';

export const pad = (num) => num.toString().padStart(2, "0");

export const game_state = $state({day_id: 0, guesses: []});

$effect.root(() => {
  $effect(() => {
    const date = new Date();
    upsert_state({
      day_id: untrack(() => game_state.day_id),
      date: `${date.getUTCFullYear()}-${pad(date.getUTCMonth() + 1)}-${pad(date.getUTCDate())}`,
      guesses: $state.snapshot(game_state.guesses)
    })
  });
})

export const audio_buffers = writable([]);
export const completions = writable([]);
export const modal_states = $state({})

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
