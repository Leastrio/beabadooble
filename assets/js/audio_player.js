export default {
  mounted() {
    this.play_btn = document.getElementById('play');
    this.progress_bar = document.getElementById('progress');
    this.handleEvent("session:set_audio", ({url}) => {
      if (this.audio) {
        this.audio.pause();
        this.audio.currentTime = 0;
        if (this.animation) { this.animation.cancel() }
      }
      this.audio = new Audio(url)
    });
    this.play_btn.addEventListener("click", () => {
      this.audio.currentTime = 0;
      if (this.animation) {
        this.animation.cancel();
      }
      this.audio.play();
      this.animation = this.progress_bar.animate({'width': this.audio.duration / 5.0 * 100 + "%"}, this.audio.duration * 1000, 'linear');
    });
  },

  destroyed() {
    if (this.audio) { this.audio.pause() }
    if (this.animation) { this.animation.cancel() }
  }
}
