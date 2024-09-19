const pad = (num) => num.toString().padStart(2, "0");

export default {
  mounted() {
    this.interval = setInterval(() => {
      let now = new Date();
      let hours = 23 - now.getUTCHours();
      let minutes = 59 - now.getUTCMinutes();
      let seconds = 59 - now.getUTCSeconds();
      this.el.innerText = `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
    })
  },

  destroyed() {
    clearInterval(this.interval);
  }
}
