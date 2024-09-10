// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {};
Hooks.Session = {
  mounted() {
    this.handleEvent("session:store", ({key, val}) => localStorage.setItem(key, val));
  }
}

Hooks.AudioPlayer = {
  mounted() {
    this.play_btn = document.getElementById('play');
    this.progress_bar = document.getElementById('progress');
    this.handleEvent("session:set_audio", ({url}) => {
      console.log(url)
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

Hooks.Autocomplete = {
  mounted() {
    this.options = Array.from(this.el.options);
    this.el.innerHTML = '';

    datalist = this.el;
    options = this.options;

    for (let e of document.getElementsByTagName('input')) {
      function filterOptions() {
        datalist.innerHTML = '';
        if (e.value != "") {
          const search = e.value.toLowerCase();

          options
            .filter(option => option.value.toLowerCase().includes(search))
            .forEach(option => datalist.appendChild(option));
        }
      }

      e.addEventListener('input', debounce(filterOptions, 200))
    }
  }
}

Hooks.Countdown = {
  mounted() {
    let pad = (num) => num.toString().padStart(2, "0");
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

function debounce(func, timeout) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => { func.apply(this, args); }, timeout);
  }
}


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken, restore: localStorage.getItem("session")},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

