export default {
  mounted() {
    this.play_btn = document.getElementById('play-btn');
    this.progress_bar = document.getElementById('progress');

    this.audio_buffers = [];
    this.audio_context = new (window.AudioContext || window.webkitAudioContext)();
    this.source = null;

    if (navigator.audioSession) {
      navigator.audioSession.type = 'playback';
    }

    this.handleEvent("session:preload_audio", async ({urls, curr_idx}) => {
      this.curr_idx = curr_idx;

      document.getElementById('play-spinner').classList.remove('hidden');
      document.getElementById('play-icon').classList.add('hidden');
      document.getElementById('play-btn').disabled = true;
      document.getElementById('skip-btn').disabled = true;

      const audio_promises = urls.map((url) => {
        return new Promise((resolve, reject) => {
          const request = new XMLHttpRequest();
          request.open('GET', url, true);
          request.responseType = 'arraybuffer';

          request.onload = () => {
            this.audio_context.decodeAudioData(request.response, (buffer) => {
              resolve(buffer);
            })
          }

          request.send();
        });
      });

      const buffers = await Promise.all(audio_promises);
      this.audio_buffers = buffers.sort((a, b) => a.duration - b.duration);
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

      if (this.source) {
        this.source.stop()
        if (this.animation) {
          this.animation.cancel()
        }
      }

      this.source = this.audio_context.createBufferSource();
      this.source.buffer = audio;
      this.source.connect(this.audio_context.destination);

      this.source.start(0)
      this.animation = this.progress_bar.animate({'width': audio.duration / 2.5 * 100 + "%"}, audio.duration * 1000, 'linear');

      this.source.onended = () => {
        this.currentSource = null;
      }
    });
  },

  destroyed() {
    if (this.audio) { this.audio.pause() }
    if (this.animation) { this.animation.cancel() }
    if (this.audioContext) { this.audioContext.close() }
  }
}
