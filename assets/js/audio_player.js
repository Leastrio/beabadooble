export default {
  mounted() {
    this.play_btn = document.getElementById('play-btn');
    this.progress_bar = document.getElementById('progress');

    this.audios = [];

    this.handleEvent("session:preload_audio", ({urls, curr_idx}) => {
      let audios_loaded = 0;
      const total_audios = urls.length;

      this.curr_idx = curr_idx;

      document.getElementById('play-spinner').classList.remove('hidden');
      document.getElementById('play-icon').classList.add('hidden');
      document.getElementById('play-btn').disabled = true;
      document.getElementById('skip-btn').disabled = true;

      urls.forEach((url) => {
        const audio = new Audio(url);
        audio.load();

        audio.oncanplaythrough = function () {
          audios_loaded++;

          if (audios_loaded === total_audios) {
            document.getElementById('play-spinner').classList.add('hidden');
            document.getElementById('play-icon').classList.remove('hidden');
            document.getElementById('play-btn').disabled = false;
            document.getElementById('skip-btn').disabled = false;
          }
        };

        this.audios.push(audio);
      });
    });

    this.handleEvent("session:next_audio", () => {
      const audio = this.audios[this.curr_idx];

      if (audio) {
        audio.pause();
        audio.currentTime = 0;
        if (this.animation) { this.animation.cancel() }
      }

      this.curr_idx++;
    });

    this.play_btn.addEventListener("click", () => {
      if (this.play_btn.disabled) return;

      const audio = this.audios[this.curr_idx];

      audio.currentTime = 0;

      if (this.animation) {
        this.animation.cancel();
      }
      audio.play().then(() => {
        this.animation = this.progress_bar.animate({'width': audio.duration / 2.5 * 100 + "%"}, audio.duration * 1000, 'linear');
      });
    });
  },

  destroyed() {
    if (this.audio) { this.audio.pause() }
    if (this.animation) { this.animation.cancel() }
  }
}
