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

import AudioPlayer from "./audio_player.js"
import Autocomplete from "./autocomplete.js"
import Countdown from "./countdown.js"
import Copy from "./copy.js"
import Settings from "./settings.js"

// Delete from localstorage cause i switched to indexeddb
if (localStorage.getItem("beabadooble") !== null) {
  localStorage.removeItem("beabadooble");
}

let db, curr_game_state;

function get_latest_game_state() {
  return new Promise((resolve, reject) => {
    const request = window.indexedDB.open("beabadooble", 1);

    request.onsuccess = (event) => {
      db = event.target.result;

      const cursorReq = db.transaction(["history"], "readonly").objectStore("history").openCursor(null, "prev");

      cursorReq.onsuccess = (event) => {
        const item = event.target.result;
        if (item) {
          resolve(item.value);
        } else {
          resolve(null);
        }
      }

      cursorReq.onerror = (event) => {
        reject(event.target.error);
      }
    };

    request.onupgradeneeded = (event) => {
      db = event.target.result;
      db.createObjectStore("history", { keyPath: "song_id" });
    }

    request.onerror = (event) => {
      reject(event.target.errorCode);
    }
  })
}

let Hooks = { AudioPlayer, Autocomplete, Countdown, Copy, Settings };

Hooks.Session = {
  mounted() {
    this.handleEvent("session:store_history", ({data}) => {
      const parsed_data = JSON.parse(data);
      db.transaction(["history"], "readwrite").objectStore("history").put(parsed_data);
      curr_game_state = parsed_data;
    });

    this.handleEvent("session:update_stats", ({stats}) => {
      localStorage.setItem("stats", stats);
    })
  }
}

document.addEventListener('dblclick', e => event.preventDefault())

get_latest_game_state().then((latest) => {
  curr_game_state = latest;

  let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
  let liveSocket = new LiveSocket("/live", Socket, {
    // longPollFallbackMs: 2500,
    params: () => {
      return {_csrf_token: csrfToken, restore: {
        game_state: curr_game_state,
        stats: localStorage.getItem("stats"),
        settings: localStorage.getItem("settings")
      }}
    },
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
  //window.liveSocket = liveSocket

});
