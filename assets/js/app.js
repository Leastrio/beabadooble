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

Hooks.Copy = {
  mounted() {
    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      let siblings = this.el.parentNode.children;
      let today = new Date();
      let text = `${siblings[0].innerText} ${pad(today.getUTCMonth() + 1)}/${pad(today.getUTCDate())}\n\n${siblings[1].innerText}\n\n<https://beabadooble.fly.dev>`;
      navigator.clipboard.writeText(text);

      let inner = this.el.children[0].children;

      inner[0].innerText = "COPIED!";
      this.el.classList.add("bg-green-200");
      this.el.classList.add("hover:bg-green-200");

      setTimeout(() => {
        inner[0].innerText = "COPY";
        this.el.classList.remove("bg-green-200");
        this.el.classList.remove("hover:bg-green-200");
      }, 900);
    })
  }
}

const pad = (num) => num.toString().padStart(2, "0");

function debounce(func, timeout) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => { func.apply(this, args); }, timeout);
  }
}

document.addEventListener('dblclick', function(event) {
  event.preventDefault();
})


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken, restore: localStorage.getItem("beabadooble")},
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

