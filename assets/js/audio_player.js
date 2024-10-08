import {Howler, Howl} from "../vendor/howler.core.min.js";

export default {
  mounted() {
    this.play_btn = document.getElementById('play-btn');
    this.progress_bar = document.getElementById('progress');

    this.audio_buffers = [];

    if (navigator.audioSession) {
      navigator.audioSession.type = 'playback';
    }

    this.handleEvent("session:preload_audio", async ({urls, curr_idx, volume}) => {
      this.curr_idx = curr_idx;

      document.getElementById('play-spinner').classList.remove('hidden');
      document.getElementById('play-icon').classList.add('hidden');
      document.getElementById('play-btn').disabled = true;
      document.getElementById('skip-btn').disabled = true;

      Howler.volume(volume / 100);

      const audio_promises = urls.map((url) => {
        return new Promise((resolve, reject) => {
          const audio = new Howl({
            src: [url],
            preload: true,
            onload: () => {
              resolve(audio);
            }
          });

          if (audio.state() === 'loaded') {
            resolve(audio);
          }
        });
      });

      const buffers = await Promise.all(audio_promises);
      this.audio_buffers = buffers.sort((a, b) => a.duration() - b.duration());
      document.getElementById('play-spinner').classList.add('hidden');
      document.getElementById('play-icon').classList.remove('hidden');
      document.getElementById('play-btn').disabled = false;
      document.getElementById('skip-btn').disabled = false;
    });

    this.handleEvent("session:next_audio", () => {
      if (this.source) {
        this.source.stop();
        if (this.animation) { this.animation.cancel() }
      }

      this.curr_idx++;
    });

    this.play_btn.addEventListener("click", async () => {
      if (this.play_btn.disabled) return;

      const audio = this.audio_buffers[this.curr_idx];

      if (audio.playing()) {
        audio.stop();

        if (this.animation) {
          this.animation.cancel();
        }
      }

      audio.play();
      this.animation = this.progress_bar.animate({'width': audio.duration() / 2.5 * 100 + "%"}, audio.duration() * 1000, 'linear');
    });
  },

  destroyed() {
    if (this.animation) { this.animation.cancel() }
    this.audio_buffers.forEach(audio => {
      audio.unload();
    });
  }
}
